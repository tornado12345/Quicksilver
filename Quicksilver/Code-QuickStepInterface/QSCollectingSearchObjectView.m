//
// QSCollectingSearchObjectView.m
// Quicksilver
//
// Created by Alcor on 3/22/05.
// Copyright 2005 Blacktree. All rights reserved.
//

#import "QSCollection.h"
#import "QSCollectingSearchObjectView.h"

@implementation QSCollectingSearchObjectView
- (void)awakeFromNib {
	[super awakeFromNib];
	collection = [NSMutableArray new];
	collecting = NO;
	collectionEdge = NSMinYEdge;
	collectionSpace = 16.0;
}
- (NSSize) cellSize {
	NSSize size = [super cellSize];
	if (collectionSpace < 0.0001)
		size.width += [collection count]*16;
	return size;
}
- (void)drawRect:(NSRect)rect {
	NSRect frame = [self frame];
	NSInteger count = [collection count];
	if (![self currentEditor] && count) {
		CGFloat totalSpace = collectionSpace+4;
		if (collectionSpace < 0.0001) {
			totalSpace = count*16+8;
		}
		frame.origin = NSZeroPoint;
		NSRect mainRect, collectRect;
		NSDivideRect(frame, &collectRect, &mainRect, totalSpace, collectionEdge);
		[[self cell] drawWithFrame:mainRect inView:self];
		[[NSColor colorWithDeviceWhite:1.0 alpha:0.92] set];
		if (collectionSpace < 0.0001)
			collectRect.origin.x += 8;
		NSInteger i;
		CGFloat iconSize = collectionSpace?collectionSpace:16;
		CGFloat opacity = collecting?1.0:0.75;
		QSObject *object;
		for (i = 0; i<count; i++) {
			object = [collection objectAtIndex:i];
			NSImage *icon = [object icon];
			[icon setSize:QSSize16];
			[icon drawInRect:NSMakeRect(collectRect.origin.x+iconSize*i, collectRect.origin.y+2, iconSize, iconSize) fromRect:rectFromSize([icon size]) operation:NSCompositingOperationSourceOver fraction:opacity];
		}
	} else {
		[super drawRect:rect];
	}
}
- (void)insertText:(id)aString replacementRange:(NSRange)replacementRange
{
	if (!collecting && ![partialString length]) {
		[self emptyCollection:nil];
	}
	[super insertText:aString replacementRange:replacementRange];
}
- (IBAction)collect:(id)sender { //Adds additional objects to a collection
	collecting = YES;
	if ([super objectValue] && ![collection containsObject:[super objectValue]]) {
		[collection addObject:[super objectValue]];
		[self updateHistory];
		[self saveMnemonic];
		[self setNeedsDisplay:YES];
	}
	[self setShouldResetSearchString:YES];
}
- (IBAction)uncollect:(id)sender { //Removes an object to a collection
	NSInteger position = -1;
	if ([collection count]) {
		position = [collection indexOfObject:[super objectValue]] - 1;
		[collection removeObject:[super objectValue]];
	}
	if (position >= 0) {
		[self selectObjectValue:[collection objectAtIndex:position]];
	} else {
		[self selectObjectValue:[collection lastObject]];
	}
	if ([collection count] <= 1) {
		// stop collecting if there's only one object
		[self emptyCollection:nil];
	}
	[self clearSearch];
	[self setNeedsDisplay:YES];
}
- (IBAction)uncollectLast:(id)sender { //Removes an object to a collection
	if ([collection count])
		[collection removeLastObject];
	if ([collection count] <= 1) {
		// stop collecting if there's only one object
		[self emptyCollection:nil];
	}
	[self setNeedsDisplay:YES];
	//if ([[resultController window] isVisible])
	//	[resultController->resultTable setNeedsDisplay:YES];}
}
- (IBAction)goForwardInCollection:(id)sender
{
	if ([collection count] <= 1) {
		return;
	}
	QSObject *selected = [super objectValue];
	NSUInteger position = [collection indexOfObject:selected];
	if (position == [collection count] - 1 || position == NSNotFound) {
		// end of the list or not in list at all, wrap to beginning
		position = 0;
	} else {
		// go forward one
		position++;
	}
	// prepare the state of the view
	[self clearSearch];
	// change the selection
	QSObject *newSelected = [collection objectAtIndex:position];
	[self selectObjectValue:newSelected];
}
- (IBAction)goBackwardInCollection:(id)sender
{
	if ([collection count] <= 1) {
		return;
	}
	QSObject *selected = [super objectValue];
	NSUInteger position = [collection indexOfObject:selected];
	if (position == 0 || position == NSNotFound) {
		// beginning of the list or not in list at all, wrap to end
		position = [collection count] - 1;
	} else {
		// go back one
		position--;
	}
	// prepare the state of the view
	[self clearSearch];
	// change the selection
	QSObject *newSelected = [collection objectAtIndex:position];
	[self selectObjectValue:newSelected];
}
- (void)clearObjectValue {
	[self emptyCollection:nil];
	[super clearObjectValue];
}
- (IBAction)emptyCollection:(id)sender {
	collecting = NO;
	[collection removeAllObjects];
}
- (IBAction)combine:(id)sender { //Resolve a collection as a single object
	[self setObjectValue:[self objectValue]];
	[self emptyCollection:sender];
}
- (id)objectValue {
	if ([collection count])
		return [QSObject objectByMergingObjects:[NSArray arrayWithArray:collection] withObject:[super objectValue]];
	else
		return [super objectValue];
}
- (BOOL)objectIsInCollection:(QSObject *)thisObject {
	return [collection containsObject:thisObject];
}
- (void)explodeCombinedObject
{
	QSObject *selected = [super objectValue];
	NSMutableArray *components;
	if ([collection count]) {
		components = [collection mutableCopy];
	} else {
		components = [[selected splitObjects] mutableCopy];
		selected = nil;
	}
	if (selected && ![components containsObject:selected]) {
		[components addObject:selected];
	}
	if ([components count] <= 1) {
		NSBeep();
		return;
	}
	[[self controller] showArray:components];
}
- (void)deleteBackward:(id)sender {
	if ([collection count] && ![partialString length]) {
		if (![collection containsObject:[super objectValue]]) {
			// search string cleared, but main object was never added to the collection
			[collection addObject:[super objectValue]];
		}
		[self uncollect:sender];
	} else {
		[super deleteBackward:sender];
    }
}
- (void)reset:(id)sender {
	collecting = NO;
	[super reset:sender];
}
- (void)redisplayObjectValue:(QSObject *)newObject
{
	if ([newObject count] > 1) {
		collection = [[newObject splitObjects] mutableCopy];
		[collection makeObjectsPerformSelector:@selector(loadIcon)];
		newObject = [collection lastObject];
	} else {
		[self emptyCollection:nil];
	}
	collecting = NO;
	[self selectObjectValue:newObject];
}
- (NSRectEdge)collectionEdge {
	return collectionEdge;
}
- (void)setCollectionEdge:(NSRectEdge)value {
	collectionEdge = value;
}
- (CGFloat)collectionSpace {
	return collectionSpace;
}
- (void)setCollectionSpace:(CGFloat)value {
	collectionSpace = value;
}

#pragma mark -
#pragma mark Touch Bar

static NSTouchBarItemIdentifier QSCollectionItemIdentifier = @"QSCollectionGroup";
static NSTouchBarItemIdentifier QSExplodeCollectionItemIdentifier = @"QSExplodeCollection";
static NSTouchBarItemIdentifier QSCollectionRemoveItemIdentifier = @"QSCollectionRemoveItem";

- (NSTouchBar *)makeTouchBar
{
	NSTouchBar *touchBar = [super makeTouchBar];
	NSArray *collectionIdentifiers = @[
		QSCollectionItemIdentifier,
		QSExplodeCollectionItemIdentifier,
		QSCollectionRemoveItemIdentifier,
	];
	touchBar.customizationAllowedItemIdentifiers = [touchBar.customizationAllowedItemIdentifiers arrayByAddingObjectsFromArray:collectionIdentifiers];
	return touchBar;
}

- (nullable NSTouchBarItem *)touchBar:(NSTouchBar *)touchBar makeItemForIdentifier:(NSTouchBarItemIdentifier)identifier
{
	BOOL collectionSelected = ([collection count] > 0);
	if ([identifier isEqualToString:QSCollectionItemIdentifier]) {
		NSButton *backButton = [NSButton buttonWithTitle:@"•,•,•" image:[NSImage imageNamed:NSImageNameTouchBarGoBackTemplate] target:self action:@selector(goBackwardInCollection:)];
		NSCustomTouchBarItem *back = [[NSCustomTouchBarItem alloc] initWithIdentifier:@"QSCollectionBack"];
		back.view = backButton;
		backButton.enabled = (collectionSelected);
		NSButton *forwardButton = [NSButton buttonWithTitle:@"•,•,•" image:[NSImage imageNamed:NSImageNameTouchBarGoForwardTemplate] target:self action:@selector(goForwardInCollection:)];
		NSCustomTouchBarItem *forward = [[NSCustomTouchBarItem alloc] initWithIdentifier:@"QSCollectionForward"];
		forward.view = forwardButton;
		forwardButton.enabled = collectionSelected;
		NSGroupTouchBarItem *collectionGroup = [NSGroupTouchBarItem groupItemWithIdentifier:QSCollectionItemIdentifier items:@[back, forward]];
		collectionGroup.customizationLabel = NSLocalizedString(@"Collection", @"");
		return collectionGroup;
	} else if ([identifier isEqualToString:QSExplodeCollectionItemIdentifier]) {
		NSButton *explodeButton = [NSButton buttonWithImage:[NSImage imageNamed:NSImageNameTouchBarListViewTemplate] target:self action:@selector(explodeCombinedObject)];
		NSCustomTouchBarItem *explodeCollection = [[NSCustomTouchBarItem alloc] initWithIdentifier:QSExplodeCollectionItemIdentifier];
		explodeCollection.view = explodeButton;
		explodeButton.enabled = collectionSelected;
		explodeCollection.customizationLabel = NSLocalizedString(@"Explode Collection", @"");
		return explodeCollection;
	} else if ([identifier isEqualToString:QSCollectionRemoveItemIdentifier]) {
		NSButton *removeButton = [NSButton buttonWithTitle:@"•,•,• ⌫" target:self action:@selector(uncollectLast:)];
		NSCustomTouchBarItem *removeFromCollection = [[NSCustomTouchBarItem alloc] initWithIdentifier:QSCollectionRemoveItemIdentifier];
		removeFromCollection.view = removeButton;
		removeButton.enabled = collectionSelected;
		removeFromCollection.customizationLabel = NSLocalizedString(@"Remove Last Item", @"");
		return removeFromCollection;
	}
	return [super touchBar:touchBar makeItemForIdentifier:identifier];
}
@end
