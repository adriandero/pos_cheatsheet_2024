
setup:
	sudo apt-get install pandoc wkhtmltopdfmak
	#curl -O https://cdnjs.cloudflare.com/ajax/libs/github-markdown-css/5.1.0/github-markdown.min.css

pdf:
	pandoc -s PosCheatSheet.md -o PosCheatSheet.html --metadata title="Cheatsheet"
#	#echo '<link rel="stylesheet" href="github-markdown.min.css">' | cat - PosCheatSheet.html > temp && mv temp PosCheatSheet.html
#	#echo '<div class="markdown-body">' | cat - PosCheatSheet.html > temp && mv temp PosCheatSheet.html
#	#echo '</div>' >> PosCheatSheet.html
	wkhtmltopdf PosCheatSheet.html PosCheatSheet.pdf
