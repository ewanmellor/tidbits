This is Punycode Cocoa by Nate Weaver (Wevah).

This has been imported into the Tidbits library by taking the important source code, and leaving the
test app and project files.  The tests have been converted from upstream SenTestingKit to XCTest.

See LICENSE in this folder for Punycode Cocoa's copyright and license.

The original Readme follows.


Punycode Cocoa
==============

v1.0 (2012)  
by Nate Weaver (Wevah)  
http://derailer.org/  
https://github.com/Wevah/Punycode-Cocoa

A simple punycode/IDNA category on NSString, based on code and documentation from RFC 3492 and RFC 3490.

To use in your own projects, all you need is NSStringPunycodeAdditions.h/m. This project includes a sample testing app.

Methods
-------

NSString
--------

	- (NSString *)punycodeEncodedString;
	- (NSString *)punycodeDecodedString;
	
Encodes or decodes a string to its punycode-encoded format.
	
	- (NSString *)IDNAEncodedString;
	
If `self` contains non-ASCII, calls `-punycodeEncodedString` and prepends `xn--`.

	- (NSString *)IDNADecodedString;

Decodes a string returned by `-IDNAEncodedString`.

	- (NSString *)encodedURLString;
	- (NSString *)decodedURLString;
	
Performs encode/decode operations on each appropriate part (the domain bits) of an URL string.

NSURL
-----
	
	+ (NSURL *)URLWithUnicodeString:(NSString *)URLString;
	
Convenience method equivalent to `[NSURL URLWithString:[URLString encodedURLString]]`.
	
	- (NSString *)decodedURLString;

Convenience method equivalent to `[[anURL absoluteString] decodedURLString]`.
