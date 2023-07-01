local json = require'json'
local socket = require("socket")
local http = require('socket.http')

local function rmDir(dir)
    local handle = io.popen('rmdir /S /Q "'..dir..'"')
    local result = handle:read("*a")
    handle:close()

    return result
end

local function mkDir(dir)
    local handle = io.popen('mkdir "'..dir..'"')
    local result = handle:read("*a")
    handle:close()

    return result
end

local function installForge(minecraftDir)
    local forgeInstaller = "forgeFiles/forge-1.19.2-43.2.4-installer.jar"
    local forgeCLI = "forgeFiles/ForgeCLI-1.0.1.jar"

    local forgeInstallerWrite = "forge-1.19.2-43.2.4-installer.jar"
    local forgeCLIWrite = "ForgeCLI-1.0.1.jar"

    local forgeInstallerFile = assert(io.open(forgeInstallerWrite, "wb"))
    local forgeCLIFile = assert(io.open(forgeCLIWrite, "wb"))

    forgeInstallerFile:write(love.filesystem.read("data", forgeInstaller):getString())
    forgeCLIFile:write(love.filesystem.read("data", forgeCLI):getString())

    forgeInstallerFile:close()
    forgeCLIFile:close()

    -- Define the command to install Forge
    local command = ('java -jar "%s" --installer "%s" --target "%s"'):format(forgeCLIWrite, forgeInstallerWrite, minecraftDir)

    local handle = io.popen(command)
    local result = handle:read("*a")
    handle:close()

    local handle = io.popen('del /f "'..forgeInstallerWrite)
    handle:close()  
    local handle = io.popen('del /f "'..forgeCLIWrite)
    handle:close()

    return result
end

local function downloadFileFromTCP(ip, port, filename)
    local tcp = assert(socket.tcp())
    tcp:connect(ip, port)

    tcp:send(filename)

    local s, status, partial = tcp:receive('*a')

    tcp:close()

    return s
end

local continue
while (continue ~= 'y' and continue ~= 'n') do
    print("If you have any mods in your mods folder this will erase those mods, do you wish to continue? (y/n)")
    continue = string.lower(io.read())
    if (continue ~= 'y' and continue ~= 'n') then
        print("Invalid input")
    end
end

if continue == 'y' then
    -- Prompt the user for the Minecraft installation directory
    print("Enter the Minecraft installation directory, or just press enter to use the default:")
    local minecraftDir = io.read()
    -- Check if input was provided, otherwise use the default directory
    if minecraftDir == "" then
        -- Get the Roaming AppData directory
        local appDataDir = os.getenv("APPDATA")
        -- Set the Minecraft installation directory to the default .minecraft folder within the Roaming AppData directory
        minecraftDir = appDataDir .. "\\.minecraft"
    end

    print("Downloading latest mods...")
    local modFiles = love.filesystem.newFileData(downloadFileFromTCP('181.ip.ply.gg', 45488, "modFiles.zip\n"), "modFiles.zip")
    love.filesystem.mount(modFiles, "modFiles")

    local installOrUpdate
    while (installOrUpdate ~= "i" and installOrUpdate ~= "u") do
        print("Install or Update (I/U)")
        installOrUpdate = string.lower(io.read())
        if (installOrUpdate ~= "i" and installOrUpdate ~= "u") then
            print("Invalid input")
        end
    end
    if installOrUpdate == 'i' then
        print("Installing Mods...")
        local modsFolder = minecraftDir.."\\mods"
        rmDir(modsFolder)
        mkDir(modsFolder)

        for line in love.filesystem.lines("modFiles/modList.txt") do
            local file = love.filesystem.read("modFiles/"..line)
            local f = io.open(modsFolder.."/"..line, "wb")
            f:write(file)
            f:close()
        end

        print("Installing Forge 1.19.2...")
        installForge(minecraftDir)
    end
    if installOrUpdate == 'u' then
        print("Installing Mods...")
        local modsFolder = minecraftDir.."\\mods"
        rmDir(modsFolder)
        mkDir(modsFolder)

        for line in love.filesystem.lines("modFiles/modList.txt") do
            local file = love.filesystem.read("modFiles/"..line)
            local f = io.open(modsFolder.."/"..line, "wb")
            f:write(file)
            f:close()
        end
    end

    love.filesystem.unmount("modFiles")

    print("Install complete, Open the minecraft launcher and run Forge 1.19.2")
    print("You may now close the program")
else
    print("You may now close the program")
end