/*
 *  For information on usage and redistribution, and for a DISCLAIMER OF ALL
 *  WARRANTIES, see the file, "LICENSE.txt," in this distribution.
 *
 */

#import <UIKit/UIKit.h>

@interface ViewController : UIViewController

@property (weak, nonatomic) IBOutlet UILabel *tempoLabel;
@property (weak, nonatomic) IBOutlet UILabel *resolutionLabel;
@property (weak, nonatomic) IBOutlet UILabel *quantumLabel;
@property (weak, nonatomic) IBOutlet UISlider *tempoSlider;
@property (weak, nonatomic) IBOutlet UISlider *resolutionSlider;
@property (weak, nonatomic) IBOutlet UISlider *quantumSlider;

@end

