build:
	if [ ! -d dist ]; then mkdir dist; fi
	if [ ! -f dist/index.html ]; then cp src/index.html dist/; fi
	if [ ! -f dist/index.css ]; then cp src/index.css dist/; fi
	if [ ! -f dist/normalize.css ]; then cp node_modules/normalize.css/normalize.css dist/; fi
	if [ ! -f dist/react.min.js ]; then cp node_modules/react/umd/react.production.min.js dist/react.min.js; fi
	if [ ! -f dist/react-dom.min.js ]; then cp node_modules/react-dom/umd/react-dom.production.min.js dist/react-dom.min.js; fi
	./node_modules/.bin/tsc
	./node_modules/.bin/browserify dist/index.js --ignore react --ignore react-dom > dist/bundle.js

clean:
	if [ -d dist ]; then rm -r dist; fi

lint:
	./node_modules/.bin/tslint src/*/* *.js
