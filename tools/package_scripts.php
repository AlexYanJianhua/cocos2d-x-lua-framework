<?php

define('DS', DIRECTORY_SEPARATOR);

class LuaPackager
{
    private $packageName    = '';
    private $rootdir        = '';
    private $rootdirLength  = 0;
    private $files          = array();
    private $modules        = array();

    function __construct($srcDir, $packageName)
    {
        $this->rootdir = realpath($srcDir);
        $this->rootdirLength = strlen($this->rootdir) + 1;
        $this->packageName = trim($packageName, '.');
        if (!empty($this->packageName))
        {
            $this->packageName = $this->packageName . '.';
        }
    }

    function dump($outputFileBasename)
    {
        $this->files = array();
        $this->modules = array();

        print("compile script files\n");
        $this->compile();
        if (empty($this->files))
        {
            printf("error.\nERROR: not found script files in %s\n", $this->rootdir);
            return;
        }

        $headerFilename = $outputFileBasename . '.h';
        printf("create C header file: %s\n", $headerFilename);
        file_put_contents($headerFilename, $this->renderHeaderFile($outputFileBasename));

        $sourceFilename = $outputFileBasename . '.c';
        printf("create C source file: %s\n", $sourceFilename);
        file_put_contents($sourceFilename, $this->renderSourceFile($outputFileBasename));

        printf("done.\n");
    }

    private function compile()
    {
        if (file_exists($this->rootdir) && is_dir($this->rootdir))
        {
            $this->files = $this->getFiles($this->rootdir);
        }

        foreach ($this->files as $path)
        {
            $filename = substr($path, $this->rootdirLength);
            $fi = pathinfo($filename);
            if ($fi['extension'] != 'lua') continue;

            $basename = ltrim($fi['dirname'] . DS . $fi['filename'], '/\\.');
            $moduleName = $this->packageName . str_replace(DS, '.', $basename);
            printf('  compile module: %s...', $moduleName);
            $bytes = $this->compileFile($path);
            if ($bytes == false)
            {
                print("error.\n");
            }
            else
            {
                print("ok.\n");
                $bytesName = 'lua_m_' . strtolower(str_replace('.', '_', $moduleName));
                $this->modules[] = array(
                    'moduleName'    => $moduleName,
                    'bytesName'     => $bytesName,
                    'functionName'  => 'luaopen_' . $bytesName,
                    'basename'      => $basename,
                    'bytes'         => $bytes,
                );
            }
        }
    }

    private function getFiles($dir)
    {
        $files = array();
        $dir = rtrim($dir, "/\\") . DS;
        $dh = opendir($dir);
        if ($dh == false) { return $files; }

        while (($file = readdir($dh)) !== false)
        {
            if ($file{0} == '.') { continue; }

            $path = $dir . $file;
            if (is_dir($path))
            {
                $files = array_merge($files, $this->getFiles($path));
            }
            elseif (is_file($path))
            {
                $files[] = $path;
            }
        }
        closedir($dh);
        return $files;
    }

    private function compileFile($path)
    {
        $tmpfile = $path . '.bytes';
        if (file_exists($tmpfile)) unlink($tmpfile);

        $command = sprintf('luac -o "%s" "%s"', $tmpfile, $path);
        passthru($command);

        if (!file_exists($tmpfile)) return false;
        $bytes = file_get_contents($tmpfile);
        unlink($tmpfile);
        return $bytes;
    }

    private function renderHeaderFile($outputFileBasename)
    {
        $headerSign = '__LUA_MODULES_' . strtoupper(md5(time())) . '_H_';

        $contents = array();
        $contents[] = <<<EOT

/* ${outputFileBasename}.h */

#ifndef ${headerSign}
#define ${headerSign}

#include "lua.h"

/*
static luaL_Reg luax_exts[] = {

EOT;

        foreach ($this->modules as $module)
        {
            $contents[] = sprintf('    {"%s", %s},',
                                  $module["moduleName"],
                                  $module["functionName"]);
        }

        $contents[] = "    {NULL, NULL}\n};\n";

        foreach ($this->modules as $module)
        {
            $contents[] = sprintf('/* %s, %s.lua */', $module['moduleName'], $module['basename']);
            $contents[] = sprintf('%s(lua_State* L);', $module['functionName']);
        }

        $contents[] = <<<EOT

#endif /* ${headerSign} */

EOT;

        return implode("\n", $contents);
    }

    private function renderSourceFile($outputFileBasename)
    {
        $contents = array();
        $contents[] = <<<EOT

/* ${outputFileBasename}.c */

#include "lua.h"
#include "lauxlib.h"
#include "${outputFileBasename}.h"

EOT;

        foreach ($this->modules as $module)
        {
            $contents[] = sprintf('/* %s, %s.lua */', $module['moduleName'], $module['basename']);
            $contents[] = sprintf('static const unsigned char %s[] = {', $module['bytesName']);
            $contents[] = $this->encodeBytes($module['bytes']);
            $contents[] = '};';
            $contents[] = '';
        }

        $contents[] = '';

        foreach ($this->modules as $module)
        {
            $functionName = $module['functionName'];
            $bytesName    = $module['bytesName'];
            $basename     = $module['basename'];

            $contents[] = <<<EOT

int ${functionName}(lua_State *L) {
    int arg = lua_gettop(L);
    luaL_loadbuffer(L,
                    (const char*)${bytesName},
                    sizeof(${bytesName}),
                    "${basename}.lua");
    lua_insert(L,1);
    lua_call(L,arg,1);
    return 1;
}

EOT;
        }

        $contents[] = '';

        return implode("\n", $contents);
    }

    private function encodeBytes($bytes)
    {
        $len      = strlen($bytes);
        $contents = array();
        $offset   = 0;
        $buffer   = array();

        while ($offset < $len)
        {
            $buffer[] = ord(substr($bytes, $offset, 1));
            if (count($buffer) == 16)
            {
                $contents[] = $this->encodeBytesBlock($buffer);
                $buffer = array();
            }
            $offset++;
        }
        if (!empty($buffer))
        {
            $contents[] = $this->encodeBytesBlock($buffer);
        }

        return implode("\n", $contents);
    }

    private function encodeBytesBlock($buffer)
    {
        $output = array();
        $len = count($buffer);
        for ($i = 0; $i < $len; $i++)
        {
            $output[] = sprintf('0x%02x,', $buffer[$i]);
        }
        return implode('', $output);
    }
}


function help()
{
    print("usage: php package_scripts.php [-p package name] dirname [output filename]\n\n");
}

if ($argc < 2)
{
    help();
    exit(1);
}

$packageName = '';
$offset = 1;
if ($argv[1] == '-p')
{
    $packageName = $argv[2];
    $offset = 3;
}

$outputFileBasename = !empty($argv[$offset + 1]) ? $argv[$offset + 1] : 'compiled_scripts';
$packager = new LuaPackager($argv[$offset], $packageName);
$packager->dump($outputFileBasename);
