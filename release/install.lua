-- Install Script for CCUI Library

-- Configuration
local RELEASE_URL = "https://raw.githubusercontent.com/nomnivore/cc-ui/main/release/ui.lua"
local DEV_BASE_URL = "https://raw.githubusercontent.com/nomnivore/cc-ui/main/ccui/"
local INSTALL_DIR = "ccui"
local MANIFEST_FILE = "https://raw.githubusercontent.com/nomnivore/cc-ui/main/manifest.json"

--- Print text in a specified color
--- @param text string|table
--- @param color ccTweaked.colors.color
local function printColor(text, color)
	local oldColor = term.getTextColor()
	term.setTextColor(color)
	if type(text) == "table" then
		for _, line in ipairs(text) do
			print(tostring(line))
		end
	else
		print(tostring(text))
	end
	term.setTextColor(oldColor)
end

--- Download a file from a URL.
--- @param url string
--- @param path string
local function download(url, path)
	printColor("Downloading [" .. path .. "]", colors.blue)
	local response = http.get(url)
	if not response then
		term.setTextColor(colors.red)
		error("Failed to download [" .. path .. "]: No response")
	end

	local body = response.readAll()
	response.close()

	if not body then
		term.setTextColor(colors.red)
		error("Failed to download [" .. path .. "]: Empty file")
	end

	local file = io.open(path, "w")
	if not file then
		term.setTextColor(colors.red)
		error("Failed to open file for writing: [" .. path .. "]")
	end

	file:write(body)
	file:close()
end

--- Create a directory
--- @param path string
local function createDir(path)
	if fs.exists(path) then
		return
	end
	printColor("Creating directory: " .. path, colors.green)
	fs.makeDir(path)
	if not fs.exists(path) then
		term.setTextColor(colors.red)
		error("Failed to create directory: " .. path)
	end
end

--- Delete a file or directory
--- @param path string
local function deletePath(path)
	if fs.exists(path) then
		printColor("Deleting existing path: " .. path, colors.green)
		fs.delete(path)
		if fs.exists(path) then
			term.setTextColor(colors.red)
			error("Failed to delete: " .. path)
		end
	end
end

--- Install the release version
local function installRelease()
	printColor("Installing CCUI (Release)...", colors.green)
	deletePath("ccui.lua")
	download(RELEASE_URL, "ccui.lua")
	printColor("CCUI Release installed successfully!", colors.green)
end

--- Install the development version
local function installDev()
	printColor("Installing CCUI (Dev)...", colors.green)

	deletePath(INSTALL_DIR)

	-- Create the main directory
	createDir(INSTALL_DIR)

	-- Download and parse the manifest file
	download(MANIFEST_FILE, "manifest.json")
	local manifest_file = io.open("manifest.json", "r")
	if not manifest_file then
		term.setTextColor(colors.red)
		error("Failed to open manifest file: " .. MANIFEST_FILE)
	end
	local manifest_content = manifest_file:read("*a")
	manifest_file:close()

	-- Remove the manifest file after reading it.
	fs.delete("manifest.json")

	local manifest = textutils.unserializeJSON(manifest_content)
	if not manifest or type(manifest) ~= "table" then
		term.setTextColor(colors.red)
		error("Failed to parse manifest file: " .. MANIFEST_FILE)
	end

	-- Iterate through the manifest and download files/create directories
	for _, entry in ipairs(manifest) do
		if entry.type == "file" then
			local filePath = entry.url
			local installPath = INSTALL_DIR .. "/" .. filePath
			local dirPath = string.match(installPath, "(.*/)") -- Extract directory
			if dirPath then
				createDir(dirPath) -- Create the directory
			end
			download(DEV_BASE_URL .. filePath, installPath)
		end
	end

	printColor("CCUI (Dev) installed successfully!", colors.green)
end

--- Main function to handle installation process
local function main()
	printColor("Welcome to the CCUI Installer!", colors.green)

	printColor(
		{
			"This script will install the CCUI library for ComputerCraft.",
			"Choose which version to install:",
			"1. Release (bundled, minified)",
			"2. Development (full source with types)",
		},
		colors.yellow
	)

	local choice = read()
	if choice == "1" then
		installRelease()
	elseif choice == "2" then
		installDev()
	else
		printColor("Invalid choice. Please run the installer again and enter '1' or '2'.", colors.red)
	end
end

-- Check for command-line arguments (optional)
-- for 'wget', the first arg is 'run' and the third arg is what we want to check
if #arg > 0 then
	local flag = arg[1]
	if flag == "run" then
		flag = arg[3]
	end
	if flag == "--release" or flag == "-r" then
		installRelease()
		return
	elseif flag == "--dev" or flag == "-d" then
		installDev()
		return
	elseif arg[1] == "run" and flag == nil then
		main()
		return
	else
		printColor("Invalid argument. Use --release or --dev.", colors.red)
		return
	end
end

--If no arguments, run interactive
main()
