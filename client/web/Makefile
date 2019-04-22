file_react = node_modules/react/umd/react.development.js
file_dom = node_modules/react-dom/umd/react-dom.development.js
file_router = node_modules/react-router-dom/umd/react-router-dom.js
ifeq ($(NODE),production)
	file_react = node_modules/react/umd/react.production.min.js
	file_dom = node_modules/react-dom/umd/react-dom.production.min.js
	file_router = node_modules/react-router-dom/umd/react-router-dom.min.js
endif

build:
	if [ ! -d dist ]; then mkdir dist; fi
	cp src/index.html dist/
	cp src/index.css dist/
	cp node_modules/normalize.css/normalize.css dist/
	cp $(file_react) dist/react.min.js
	cp $(file_dom) dist/react-dom.min.js
	cp $(file_router) dist/react-router.min.js
	./node_modules/.bin/tsc
	./node_modules/.bin/browserify dist/index.js --ignore react --ignore react-dom --ignore react-router-dom > dist/bundle.js

clean:
	if [ -d dist ]; then rm -r dist; fi

lint:
	./node_modules/.bin/tslint src/*/* *.js
