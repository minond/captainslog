build:
	if [ ! -d dist ]; then mkdir dist; fi
	cp src/index.html dist/
	cp src/index.css dist/
	cp node_modules/react-datepicker/dist/react-datepicker.css dist/
	./node_modules/.bin/tsc
	./node_modules/.bin/browserify -t browserify-css dist/index.js > dist/bundle.js

clean:
	if [ -d dist ]; then rm -r dist; fi

lint:
	./node_modules/.bin/tslint src/*/* *.js
