//
//  PatchTableViewCell.m
//  PolyPatch
//
//  Created by Richard Eakin on 21/02/11.
/**
 * This software is copyrighted by Richard Eakin. 
 * The following terms (the "Standard Improved BSD License") apply to 
 * all files associated with the software unless explicitly disclaimed 
 * in individual files:
 * 
 * Redistribution and use in source and binary forms, with or without
 * modification, are permitted provided that the following conditions are
 * met:
 * 
 * 1. Redistributions of source code must retain the above copyright
 * notice, this list of conditions and the following disclaimer.
 * 2. Redistributions in binary form must reproduce the above  
 * copyright notice, this list of conditions and the following 
 * disclaimer in the documentation and/or other materials provided
 * with the distribution.
 * 3. The name of the author may not be used to endorse or promote
 * products derived from this software without specific prior 
 * written permission.
 * 
 * THIS SOFTWARE IS PROVIDED BY THE AUTHOR ``AS IS'' AND ANY
 * EXPRESS OR IMPLIED WARRANTIES, INCLUDING, BUT NOT LIMITED TO,
 * THE IMPLIED WARRANTIES OF MERCHANTABILITY AND FITNESS FOR A
 * PARTICULAR PURPOSE ARE DISCLAIMED. IN NO EVENT SHALL THE AUTHOR
 * BE LIABLE FOR ANY DIRECT, INDIRECT, INCIDENTAL, SPECIAL,
 * EXEMPLARY, OR CONSEQUENTIAL DAMAGES (INCLUDING, BUT NOT LIMITED
 * TO, PROCUREMENT OF SUBSTITUTE GOODS OR SERVICES; LOSS OF USE,   
 * DATA, OR PROFITS; OR BUSINESS INTERRUPTION) HOWEVER CAUSED AND
 * ON ANY THEORY OF LIABILITY, WHETHER IN CONTRACT, STRICT
 * LIABILITY, OR TORT (INCLUDING NEGLIGENCE OR OTHERWISE) ARISING
 * IN ANY WAY OUT OF THE USE OF THIS SOFTWARE, EVEN IF ADVISED OF
 * THE POSSIBILITY OF SUCH DAMAGE.
 */

#import "PatchTableViewCell.h"
#import "PdBase.h"

@interface PatchTableViewCell ()

@property (nonatomic, retain) UISlider *pitchSlider;

- (void)pitchSliderValueChanged:(UISlider *)sender;

@end

@implementation PatchTableViewCell

@synthesize dollarZero = dollarZero_;
@synthesize pitchSlider = pitchSlider_;

- (id)initWithDollarZeroArg:(int)dollarZero reuseIdentifier:(NSString *)reuseIdentifier {
    if (self = [super initWithStyle:UITableViewCellStyleDefault reuseIdentifier:reuseIdentifier]) {
		self.dollarZero = dollarZero;
		self.backgroundColor = [UIColor brownColor];
		self.selectionStyle = UITableViewCellSelectionStyleNone;
		self.pitchSlider = [[[UISlider alloc] init] autorelease];
		self.pitchSlider.minimumValue = 0;
		self.pitchSlider.maximumValue = 30;
		self.pitchSlider.continuous = YES;
		[self.pitchSlider addTarget:self action:@selector(pitchSliderValueChanged:) forControlEvents:UIControlEventValueChanged];
		self.pitchSlider.value = 5;
		[self pitchSliderValueChanged:self.pitchSlider];
		[self addSubview:self.pitchSlider];
    }
    return self;
}

- (void) layoutSubviews {
	[super layoutSubviews];
	self.pitchSlider.frame = CGRectMake(self.bounds.size.width  * 0.6,
										self.bounds.size.height * 0.3,
										self.bounds.size.width  * 0.3,
										self.bounds.size.height * 0.5);
}

- (void)dealloc {
	self.pitchSlider = nil;
    [super dealloc];
}

// Here we send the pitch value to only the patch specified by the $0 arg associated with this table cell
- (void)pitchSliderValueChanged:(UISlider *)sender {
	[PdBase sendFloat:sender.value toReceiver:[NSString stringWithFormat:@"%d-pitch", self.dollarZero]];
}

@end
