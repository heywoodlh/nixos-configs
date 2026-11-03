#!/usr/bin/env python3
# Ensure every display has at least COUNT spaces by editing
# com.apple.spaces.plist, then restart the Dock.
import json
import os
import plistlib
import subprocess

COUNT = 4
PATH = os.path.expanduser("~/Library/Preferences/com.apple.spaces.plist")

with open(PATH, "rb") as f:
    plist = plistlib.load(f)
md = plist["SpacesDisplayConfiguration"]["Management Data"]
props = plist["SpacesDisplayConfiguration"]["Space Properties"]

changed = False
for mon in md["Monitors"]:
    while len(mon["Spaces"]) < COUNT:
        s = mon["Spaces"][-1]
        mon["Spaces"].append({
            "id64": s["id64"] + 1,
            "ManagedSpaceID": s["ManagedSpaceID"] + 1,
            "wsid": s["wsid"] + 1,
            "type": 0,
            "uuid": "",
        })
        changed = True
    mon["Current Space"] = mon["Spaces"][0]

if changed:
    total = sum(len(m["Spaces"]) for m in md["Monitors"])
    while len(props) < total:
        props.append({"name": "", "windows": []})
    plist["SpacesDisplayConfiguration"]["Space Properties"] = props[:total]
    with open(PATH, "wb") as f:
        plistlib.dump(plist, f)
    subprocess.run(["/bin/launchctl", "kickstart", "-k",
                    f"gui/{os.getuid()}/com.apple.Dock.agent"], check=False)
