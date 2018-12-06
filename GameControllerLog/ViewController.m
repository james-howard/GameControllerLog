//
//  ViewController.m
//  GameControllerLog
//
//  Created by James Howard on 12/5/18.
//  Copyright © 2018 jh. All rights reserved.
//

#import "ViewController.h"

#import <GameController/GameController.h>

@interface ViewController ()

@property IBOutlet UITextView *text;

@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];

    [_text.textStorage.mutableString setString:@""];
    [self registerForControllerNotifications];
    [self connectControllers];
}

- (void)log:(NSString *)format, ...
{
    va_list args;
    va_start(args, format);
    NSString *msg = [[NSString alloc] initWithFormat:format arguments:args];
    va_end(args);

    msg = [msg stringByAppendingString:@"\n"];

    [_text.textStorage.mutableString appendString:msg];
    [_text scrollRangeToVisible:NSMakeRange(_text.text.length-1, 0)];
}

- (void)registerForControllerNotifications {
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(controllerDidConnect:) name:GCControllerDidConnectNotification object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(controllerDidDisconnect:) name:GCControllerDidDisconnectNotification object:nil];
}

- (void)controllerDidConnect:(NSNotification *)note
{
    [self log:@"didConnect: %@", note];
    [self connectControllers];
}

- (void)controllerDidDisconnect:(NSNotification *)note
{
    [self log:@"didDisconnect: %@", note];
    [self connectControllers];
}

- (void)connectControllers {
    NSMutableArray *controllers = [[GCController controllers] mutableCopy];

    [self log:@"connectControllers saw %tu controllers", controllers.count];

    NSUInteger i = 0;
    for (GCController *controller in controllers)
    {
        [self log:@"saw controller %@ (%@) setting index to %tu", controller, controller.vendorName, i];
        controller.playerIndex = i;

        if (controller.extendedGamepad) {
            [self log:@"controller is extended"];
            controller.extendedGamepad.valueChangedHandler = ^(GCExtendedGamepad * _Nonnull gamepad, GCControllerElement * _Nonnull element) {
                [self log:@"controller %tu updated element %@", gamepad.controller.playerIndex, element];
            };
            if (controller.extendedGamepad.leftThumbstickButton) {
                [self log:@"controller has L3"];
            }
            if (controller.extendedGamepad.rightThumbstickButton) {
                [self log:@"controller has R3"];
            }
        } else if (controller.microGamepad)
        {
            [self log:@"controller is micro"];
            controller.microGamepad.valueChangedHandler = ^(GCMicroGamepad * _Nonnull gamepad, GCControllerElement * _Nonnull element) {
                [self log:@"controller %tu updated element %@", gamepad.controller.playerIndex, element];
            };
        }
    }

}



@end
