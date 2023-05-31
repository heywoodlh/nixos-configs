''
marp-template () {
	local error
	[[ -z $1 ]] && echo "usage: $0 filename.md" && error=true
	[[ $1 == '--help' ]] && echo "usage: $0 filename.md" && error=true

	if [[ ''${error} != 'true' ]]
	then
		filename="$1"
		cat > "''${filename}" << EOF
---
marp: true
title: Slide Title
description: Slide description
paginate: true
_paginate: false
---

# <!--fit--> Title of my presentation!

#### \*Description of presentation\*

<footer>
https://github.com/heywoodlh/repo-name
</footer>

-------------------------------------------------

### Spencer Heywood

Blog: __https://the-empire.systems__

Github: __https://github.com/heywoodlh/__

<footer>
https://github.com/heywoodlh/repo-name/
</footer>

-------------------------------------------------
EOF
		vim "''${filename}"
	fi

}
''
