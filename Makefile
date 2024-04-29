
setup:
	sudo apt-get install pandoc wkhtmltopdfmak

pdf:
	pandoc -s PosCheatSheet.md -o PosCheatSheet.html --metadata title="Cheatsheet"
	wkhtmltopdf --enable-local-file-access  PosCheatSheet.html PosCheatSheet.pdf
