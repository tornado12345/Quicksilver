//
//  TestQSSense.m
//  Quicksilver
//
//  Created by Etienne on 15/04/2017.
//
//

#import <XCTest/XCTest.h>

@interface TestQSSense : XCTestCase

@end

@implementation TestQSSense

const float ACC = 0.00001;

- (void)testScoreSimple {
	CFStringRef str  = CFSTR("Test string");
	CGFloat score = 0;

	score = QSScoreForAbbreviation(str, CFSTR("t"), nil);
	XCTAssertEqualWithAccuracy(score, 0.90909, ACC);

	score = QSScoreForAbbreviation(str, CFSTR("ts"), nil);
	XCTAssertEqualWithAccuracy(score, 0.92727, ACC);

	score = QSScoreForAbbreviation(str, CFSTR("te"), nil);
	XCTAssertEqualWithAccuracy(score, 0.91818, ACC);

	score = QSScoreForAbbreviation(str, CFSTR("tet"), nil);
	XCTAssertEqualWithAccuracy(score, 0.93636, ACC);

	score = QSScoreForAbbreviation(str, CFSTR("str"), nil);
	XCTAssertEqualWithAccuracy(score, 0.91818, ACC);

	score = QSScoreForAbbreviation(str, CFSTR("tstr"), nil);
	XCTAssertEqualWithAccuracy(score, 0.79090, ACC);

	score = QSScoreForAbbreviation(str, CFSTR("ng"), nil);
	XCTAssertEqualWithAccuracy(score, 0.63636, ACC);
}

- (void)testScoreLongString {
	CFStringRef str = CFSTR("This is a really long test string for testing");
	CGFloat score = 0;

	score = QSScoreForAbbreviation(str, CFSTR("t"), nil);
	XCTAssertEqualWithAccuracy(score, 0.90222, ACC);

	score = QSScoreForAbbreviation(str, CFSTR("ts"), nil);
	XCTAssertEqualWithAccuracy(score, 0.88666, ACC);

	score = QSScoreForAbbreviation(str, CFSTR("te"), nil);
	XCTAssertEqualWithAccuracy(score, 0.80777, ACC);

	score = QSScoreForAbbreviation(str, CFSTR("tet"), nil);
	XCTAssertEqualWithAccuracy(score, 0.81222, ACC);

	score = QSScoreForAbbreviation(str, CFSTR("str"), nil);
	XCTAssertEqualWithAccuracy(score, 0.78555, ACC);

	score = QSScoreForAbbreviation(str, CFSTR("tstr"), nil);
	XCTAssertEqualWithAccuracy(score, 0.67777, ACC);

	score = QSScoreForAbbreviation(str, CFSTR("testi"), nil);
	XCTAssertEqualWithAccuracy(score, 0.74000, ACC);

	score = QSScoreForAbbreviation(str, CFSTR("for"), nil);
	XCTAssertEqualWithAccuracy(score, 0.75888, ACC);

	score = QSScoreForAbbreviation(str, CFSTR("ng"), nil);
	XCTAssertEqualWithAccuracy(score, 0.74666, ACC);
}

- (void)testLongString {
	CFStringRef str = CFSTR("This excellent string tells us an interesting story");
	CFRange strRange = CFRangeMake(0, 27); // tells^
	CFStringRef abbr = CFSTR("test");
	CFRange abbrRange = CFRangeMake(0, CFStringGetLength(abbr));
	CGFloat score = 0;
	const int STEP = 4;
	NSMutableIndexSet *indexes = [[NSMutableIndexSet alloc] init];
	NSIndexSet *results = nil;

	score = QSScoreForAbbreviationWithRanges(str, CFSTR("test"), indexes, strRange, abbrRange);
	XCTAssertEqualWithAccuracy(score, 0.74074, ACC);
	results = [NSIndexSet indexSetFromArray:@[@(0), @(5), @(15), @(16), @(22), @(23)]];
	XCTAssertEqualObjects(indexes, results);

	strRange.length += STEP;
	score = QSScoreForAbbreviationWithRanges(str, CFSTR("test"), indexes, strRange, abbrRange);
	XCTAssertEqualWithAccuracy(score, 0.76129, ACC);
	results = [NSIndexSet indexSetFromArray:@[@(0), @(5), @(15), @(16), @(22), @(23), @(26)]];
	XCTAssertEqualObjects(indexes, results);

	strRange.length += STEP;
	score = QSScoreForAbbreviationWithRanges(str, CFSTR("test"), indexes, strRange, abbrRange);
	XCTAssertEqualWithAccuracy(score, 0.77714, ACC);
	results = [NSIndexSet indexSetFromArray:@[@(0), @(5), @(15), @(16), @(22), @(23), @(26)]];
	XCTAssertEqualObjects(indexes, results);

	strRange.length += STEP;
	score = QSScoreForAbbreviationWithRanges(str, CFSTR("test"), indexes, strRange, abbrRange);
	XCTAssertEqualWithAccuracy(score, 0.74230, ACC);
	results = [NSIndexSet indexSetFromArray:@[@(0), @(5), @(15), @(16), @(22), @(23), @(26), @(36)]];
	XCTAssertEqualObjects(indexes, results);

	strRange.length += STEP;
	score = QSScoreForAbbreviationWithRanges(str, CFSTR("test"), indexes, strRange, abbrRange);
	XCTAssertEqualWithAccuracy(score, 0.69883, ACC);
	results = [NSIndexSet indexSetFromArray:@[@(0), @(5), @(15), @(16), @(22), @(23), @(26), @(36), @(40), @(41)]];
	XCTAssertEqualObjects(indexes, results);

	strRange.length += STEP;
	score = QSScoreForAbbreviationWithRanges(str, CFSTR("test"), indexes, strRange, abbrRange);
	XCTAssertEqualWithAccuracy(score, 0.71595, ACC);
	results = [NSIndexSet indexSetFromArray:@[@(0), @(5), @(15), @(16), @(22), @(23), @(26), @(36), @(40), @(41)]];
	XCTAssertEqualObjects(indexes, results);

	strRange.length += STEP;
	score = QSScoreForAbbreviationWithRanges(str, CFSTR("test"), indexes, strRange, abbrRange);
	XCTAssertEqualWithAccuracy(score, 0.73039, ACC);
	results = [NSIndexSet indexSetFromArray:@[@(0), @(5), @(15), @(16), @(22), @(23), @(26), @(36), @(40), @(41)]];
	XCTAssertEqualObjects(indexes, results);
}

- (void)testPerformance {
    [self measureBlock:^{
		CFStringRef str  = CFSTR("Test string");
		CFStringRef abbr = CFSTR("tsg");

		QSScoreForAbbreviationWithRanges(str, abbr, nil,
										 CFRangeMake(0, CFStringGetLength(str)),
										 CFRangeMake(0, CFStringGetLength(abbr)));
	}];
}

- (void)testPerformanceMicro {
	[self measureBlock:^{
		CFStringRef str  = CFSTR("This is a really long test string for testing");
		CFStringRef abbr = CFSTR("tsg");

		for (int i = 0; i <= 100000; i++) {
			QSScoreForAbbreviationWithRanges(str, abbr, nil,
											 CFRangeMake(0, CFStringGetLength(str)),
											 CFRangeMake(0, CFStringGetLength(abbr)));
		}
	}];
}

@end
