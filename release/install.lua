-- Install Script for CCUI Library

-- Configuration
local RELEASE_URL = "https://raw.githubusercontent.com/nomnivore/cc-ui/main/release/ui.lua"
local DEV_BASE_URL = "https://raw.githubusercontent.com/nomnivore/cc-ui/main/ccui/"
local INSTALL_DIR = "ccui"
local MANIFEST_FILE = "manifest.json"

--- Download a file from a URL.
--- @param url string
--- @param path string
local function download(url, path)
	print("Downloading: " .. url .. " to " .. path)
	local response = http.get(url)
	if not response then
		error("Failed to download " .. url .. ": No response")
	end

	local body = response.readAll()
	response.close()

	if not body then
		error("Failed to download " .. url .. ": Empty file")
	end

	local file = io.open(path, "w")
	if not file then
		error("Failed to open file for writing: " .. path)
	end

	file:write(body)
	file:close()
	print("Downloaded successfully.")
end

--- Create a directory
--- @param path string
local function createDir(path)
	if fs.exists(path) then
		return
	end
	print("Creating directory: " .. path)
	fs.makeDir(path)
	if not fs.exists(path) then
		error("Failed to create directory: " .. path)
	end
end

--- Delete a file or directory
--- @param path string
local function deletePath(path)
	if fs.exists(path) then
		print("Deleting existing path: " .. path)
		if fs.isDir(path) then
			fs.deleteDir(path)
		else
			fs.delete(path)
		end
		if fs.exists(path) then
			error("Failed to delete: " .. path)
		end
	end
end

--- Install the release version
local function installRelease()
	print("Installing CCUI (Release Version)...")
	deletePath("ui.lua")
	download(RELEASE_URL, "ui.lua")
	print("CCUI Release Version installed successfully!")
end

--- Install the development version
local function installDev()
	print("Installing CCUI (Development Version)...")

	deletePath(INSTALL_DIR)

	-- Create the main directory
	createDir(INSTALL_DIR)

	-- Download and parse the manifest file
	download(DEV_BASE_URL .. MANIFEST_FILE, MANIFEST_FILE)
	local manifest_file = io.open(MANIFEST_FILE, "r")
	if not manifest_file then
		error("Failed to open manifest file: " .. MANIFEST_FILE)
	end
	local manifest_content = manifest_file:read("*a")
	manifest_file:close()

	-- Remove the manifest file after reading it.
	fs.delete(MANIFEST_FILE)

	local manifest = textutils.jsonDecode(manifest_content)

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

	print("CCUI Development Version installed successfully!")
end

--- Main function to handle installation process
local function main()
	print("Welcome to the CCUI Installer!")
	print("This script will install the CCUI library for ComputerCraft.")
	print("Choose which version to install:")
	print("1. Release Version (Single file, optimized)")
	print("2. Development Version (Full source, for development)")

	local choice = read()
	if choice == "1" then
		installRelease()
	elseif choice == "2" then
		installDev()
	else
		print("Invalid choice. Please run the installer again and enter '1' or '2'.")
	end
end

-- Check for command-line arguments (optional)
if #arg > 0 then
	if arg[1] == "--release" or arg[1] == "-r" then
		installRelease()
	elseif arg[1] == "--dev" or arg[1] == "-d" then
		installDev()
	else
		print("Invalid argument. Use --release or --dev.")
	end
else
	--If no arguments, run interactive
	main()
end
