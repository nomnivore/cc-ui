-- Install Script for CCUI Library

-- Configuration
local RELEASE_URL = "https://raw.githubusercontent.com/nomnivore/cc-ui/main/release/ui.lua" -- Replace with your actual raw file URL
local DEV_BASE_URL = "https://raw.githubusercontent.com/nomnivore/cc-ui/main/ccui/"      -- Replace with your actual raw directory URL (now the root for manifest)
local INSTALL_DIR = "ccui"                               -- Directory for dev install
local MANIFEST_FILE = "manifest.json"               -- Name of the manifest file

-- Helper Functions
local function download(url, path)
    -- Function to download a file from a URL.
    -- Uses ComputerCraft's built-in http.get, handles errors.
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

local function createDir(path)
    -- Function to create a directory, handles errors
    if fs.exists(path) then return end -- No need to create if it exists
    print("Creating directory: " .. path)
    fs.makeDir(path)
    if not fs.exists(path) then
        error("Failed to create directory: " .. path)
    end
end

local function deletePath(path)
    -- Function to delete a file or directory
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


local function installRelease()
    -- Function to install the release version
    print("Installing CCUI (Release Version)...")
    deletePath("ui.lua") -- Delete old release
    download(RELEASE_URL, "ui.lua") --Installs to root
    print("CCUI Release Version installed successfully!")
end

local function installDev()
    -- Function to install the development version
    print("Installing CCUI (Development Version)...")

    deletePath(INSTALL_DIR) -- Delete old dev install

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

-- Main function
local function main()
    -- Main function to handle installation process
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
