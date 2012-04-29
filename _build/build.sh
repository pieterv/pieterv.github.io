#!/usr/bin/env node

var fs = require( 'fs' ),
	uglify = require( 'uglify-js' ),
	less = require( 'less' );

var path = {
		dev: __dirname + '/',
		built: __dirname + '/../'
	},
	files = {
		html: [ 'index.html' ],
		head_js: 'js/head.js',
		less: 'css/style.less'
	};

//
// Setup global files
//

// JS
function getHeadJs( cb ) {
	var head_js, head_ast,
		jsp = uglify.parser,
		pro = uglify.uglify;

	head_js = fs.readFileSync( path.dev + files.head_js, 'utf8' );

	head_ast = jsp.parse( head_js ); // parse code and get the initial AST
	head_ast = pro.ast_mangle( head_ast ); // get a new AST with mangled names
	head_ast = pro.ast_squeeze( head_ast ); // get an AST with compression optimizations
	head_js = pro.gen_code( head_ast, {} ); // compressed code here

	cb( null, head_js );
}

// CSS
function getCss( cb ) {
	var less_file = fs.readFileSync( path.dev + files.less, 'utf8' );

	less.render( less_file, cb );
}

function generate( head_js, css ) {

	// Setup html files
	files.html.forEach( function( file_name ) {
		var page;

		page = fs.readFileSync( path.dev + file_name, 'utf8' );

		page = page.replace( '{{head_js}}', head_js ).replace( '{{css}}', css );

		fs.writeFileSync( path.built + file_name, page );

	} );

}

function run() {

	getHeadJs( function( e, js ) {
		if ( !e ) getCss( function( e, css ) {
			if ( !e ) {
				generate( js, css );
				console.log( "BUILT!" );
			}
		} );
	} );

}

fs.watchFile( path.dev + files.head_js, run );
fs.watchFile( path.dev + files.less, run );
files.html.forEach( function( file_name ) {
	fs.watchFile( path.dev + file_name, run );
} );

run();
