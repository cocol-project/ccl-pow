.DEFAULT_GOAL := prepare


prepare: format ameba test docs

format:
	crystal tool format

ameba:
	ameba

test:
	crystal spec --error-trace -t -Dpreview_mt
	
docs:
	crystal docs
