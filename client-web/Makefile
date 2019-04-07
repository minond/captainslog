build:
	if [ ! -d dist ]; then mkdir dist; fi
	cp src/index.html dist/
	cp src/index.css dist/
	cp node_modules/normalize.css/normalize.css dist/
	cp node_modules/react/umd/react.production.min.js dist/react.min.js
	cp node_modules/react-dom/umd/react-dom.production.min.js dist/react-dom.min.js
	./node_modules/.bin/tsc
	./node_modules/.bin/browserify dist/index.js --ignore react --ignore react-dom > dist/bundle.js

clean:
	if [ -d dist ]; then rm -r dist; fi

lint:
	./node_modules/.bin/tslint src/*/* *.js
