#!/usr/bin/env texlua
--[[
Gregorio font automatic installation script.
Copyright (C) 2010-2017 Gregorio Project authors

This program is free software: you can redistribute it and/or modify
it under the terms of the GNU General Public License as published by
the Free Software Foundation, either version 3 of the License, or
(at your option) any later version.

This program is distributed in the hope that it will be useful,
but WITHOUT ANY WARRANTY; without even the implied warranty of
MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.	See the
GNU General Public License for more details.

You should have received a copy of the GNU General Public License
along with this program. If not, see <http://www.gnu.org/licenses/>.

This texlua script is called in order to install the extra fonts which are not
included in the default installation of Gregorio.
--]]

require("lfs")

kpse.set_program_name('luatex')

local pathsep = '/'

local function fixpath(path)
  return path
end

local function remove_trailing_slash(path)
  return path:gsub("/$" ,"")
end

local function basename(path)
  return path:gsub("^[^/]+/" ,"")
end

if os.type == "windows" or os.type == "msdos" then
  pathsep = '\\'
  fixpath = function(path)
    return path:gsub("/", "\\")
  end
  remove_trailing_slash = function(path)
    return path:gsub("\\$" ,"")
  end
  basename = function(path)
    return path:gsub("^[^\\]+\\" ,"")
  end
end

local font_files = {
    "gregorio.ttf",
    "gregorio-hollow.ttf",
    "gregorio-hole.ttf",
    "gregorio-op.ttf",
    "gregorio-op-hollow.ttf",
    "gregorio-op-hole.ttf",
    "granapadano.ttf",
    "granapadano-hollow.ttf",
    "granapadano-hole.ttf",
    "granapadano-op.ttf",
    "granapadano-op-hollow.ttf",
    "granapadano-op-hole.ttf",
}

local source_files = {
    "gregorio-base.sfd",
    "granapadano-base.sfd",
}

function io.loaddata(filename,textmode)
  local f = io.open(filename,(textmode and 'r') or 'rb')
  if f then
    local data = f:read('*all')
    f:close()
    return data
  else
    return nil
  end
end

function io.savedata(filename,data,joiner)
  local f = io.open(filename,"wb")
  if f then
    f:write(data or "")
    f:close()
    return true
  else
    return false
  end
end

function copy_one_file(src, dest)
  local destfile = dest..basename(src)
  print(src.." -> "..destfile)
  io.savedata(destfile, io.loaddata(src))
end

local install_dir = arg[1] or "auto"
if install_dir == "auto" then
  font_target = "greciliae.ttf"
  font_directory = kpse.find_file(font_target,"truetype fonts")
  if font_directory then
    font_directory = font_directory:sub(1,-string.len(font_target)-1)
  else
    print("I can't find greciliae.ttf.  Are you sure Gregorio is installed?")
    do return end
  end
  source_target = "greciliae-base.sfd"
  source_directory = kpse.find_file(source_target,"mf")
  if source_directory then
    source_directory = source_directory:sub(1,-string.len(source_target)-1)
  else
    print("I can't find greciliae-base.sfd.  Are you sure Gregorio is installed?")
    do return end
  end
elseif install_dir == "user" then
  install_dir = kpse.expand_var("$TEXMFHOME")
  font_directory = fixpath(install_dir.."/fonts/truetype/public/gregoriotex/")
  source_directory = fixpath(install_dir.."/fonts/source/gregoriotex/")
elseif install_dir == "system" then
  install_dir = kpse.expand_var("$TEXMFLOCAL")
  font_directory = fixpath(install_dir.."/fonts/truetype/public/gregoriotex/")
  source_directory = fixpath(install_dir.."/fonts/source/gregoriotex/")
else
  font_directory = fixpath(install_dir.."/fonts/truetype/public/gregoriotex/")
  source_directory = fixpath(install_dir.."/fonts/source/gregoriotex/")
end

if not lfs.isdir(install_dir) then
  start,stop = string.find(install_dir,pathsep)
  while start do
    if not lfs.isdir(install_dir:sub(1,start)) then
      lfs.mkdir(install_dir:sub(1,start))
    end
    start,stop = string.find(install_dir,pathsep,stop+1)
  end
  lfs.mkdir(install_dir)
end

if not lfs.isdir(font_directory) then
  print("making "..font_directory)
  if not lfs.isdir(install_dir.."/fonts/truetype/public/") then
    if not lfs.isdir(install_dir.."/fonts/truetype/" ) then
      if not lfs.isdir(install_dir.."/fonts/") then
        lfs.mkdir(install_dir.."/fonts/")
      end
      lfs.mkdir(install_dir.."/fonts/truetype/")
    end
    lfs.mkdir(install_dir.."/fonts/truetype/public/")
  end
  lfs.mkdir(font_directory)
end
if not lfs.isdir(source_directory) then
  print("making "..source_directory)
  if not lfs.isdir(install_dir.."/fonts/source/") then
    lfs.mkdir(install_dir.."/fonts/source/")
  end
  lfs.mkdir(source_directory)
end

-- truetype font files
for _, file in pairs(font_files) do
  copy_one_file(file,font_directory)
end

-- source files
for _, file in pairs(source_files) do
  copy_one_file(file,source_directory)
end
