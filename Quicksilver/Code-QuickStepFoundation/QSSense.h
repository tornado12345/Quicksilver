//
//  QSense.h
//  QSqSense
//
//  Created by Alcor on 11/22/04.
//  Copyright 2004 Blacktree. All rights reserved.
//

#import <Cocoa/Cocoa.h>


CGFloat QSScoreForAbbreviation(CFStringRef string, CFStringRef abbr, id hitMask);
CGFloat QSScoreForAbbreviationOrTransliteration(CFStringRef str, CFStringRef abbr, id mask);
CGFloat QSScoreForAbbreviationWithRanges(CFStringRef str, CFStringRef abbr, id mask, CFRange strRange, CFRange abbrRange);
