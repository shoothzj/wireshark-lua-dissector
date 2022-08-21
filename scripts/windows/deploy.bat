if not exist "%UserProfile%\AppData\Roaming\Wireshark\Plugins\3.4" mkdir "%UserProfile%\AppData\Roaming\Wireshark\Plugins"
SET DIR=%~dp0..\..\
copy "%DIR%\pulsar\pulsar_dissector.lua" "%UserProfile%\AppData\Roaming\Wireshark\Plugins\pulsar_dissector.lua"
copy "%DIR%\bookkeeper\bookkeeper_dissector.lua" "%UserProfile%\AppData\Roaming\Wireshark\Plugins\bookkeeper_dissector.lua"
copy "%DIR%\zookeeper\zookeeper_dissector.lua" "%UserProfile%\AppData\Roaming\Wireshark\Plugins\zookeeper_dissector.lua"
