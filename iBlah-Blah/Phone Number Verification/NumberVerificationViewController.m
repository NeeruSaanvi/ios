//
//  NumberVerificationViewController.m
//  iBlah-Blah
//
//  Created by webHex on 08/09/18.
//  Copyright © 2018 webHax. All rights reserved.
//

#import "NumberVerificationViewController.h"
#import "OTPViewController.h"
#import "HomeViewController.h"

@interface NumberVerificationViewController (){
     NSString *str_Cc;
     IndecatorView *ind;
     BOOL doneCancleKeyBoard;
}

@end

@implementation NumberVerificationViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view from its nib.
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(keyboardWillShow:) name:UIKeyboardWillShowNotification object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(keyboardWillShow:) name:UIKeyboardWillHideNotification object:nil];
    
    NSString *countryIdentifier = [[NSLocale currentLocale] objectForKey: NSLocaleCountryCode];
    str_Cc= [NSString stringWithFormat:@"+%@",[[self getCountryCodeDictionary] objectForKey:countryIdentifier]];
    

   ind=[[IndecatorView alloc]initWithFrame:CGRectMake(0, 0, self.view.frame.size.width, self.view.frame.size.width)];
    
    
    NSUserDefaults *prefs = [NSUserDefaults standardUserDefaults];
    NSString *countryCode= [prefs objectForKey:@"name"];
    [_btnSelectCountry setTitle:[NSString stringWithFormat:@"%@ %@",str_Cc, countryIdentifier] forState:UIControlStateNormal];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

-(void)viewWillAppear:(BOOL)animated{
    [super viewWillAppear:animated];
    [self resignKeyBoard];
    
    self.navigationController.navigationBarHidden=YES;

    
    UIToolbar* numberToolbar = [[UIToolbar alloc]initWithFrame:CGRectMake(0, 0, self.view.frame.size.width, 50)];
    numberToolbar.barStyle = UIBarStyleBlackTranslucent;
    numberToolbar.items = [NSArray arrayWithObjects:
                           [[UIBarButtonItem alloc]initWithTitle:@"Cancel" style:UIBarButtonItemStylePlain target:self action:@selector(cancelNumberPad)],
                           [[UIBarButtonItem alloc]initWithBarButtonSystemItem:UIBarButtonSystemItemFlexibleSpace target:nil action:nil],
                           [[UIBarButtonItem alloc]initWithTitle:@"Done" style:UIBarButtonItemStyleDone target:self action:@selector(doneWithNumberPad)],
                           nil];
    [numberToolbar sizeToFit];
    self.txtMobleNo.inputAccessoryView = numberToolbar;
     doneCancleKeyBoard=NO;
}


-(void)viewWillDisappear:(BOOL)animated{
    [super viewWillDisappear:animated];
    [self.txtMobleNo resignFirstResponder];
    //[ind removeFromSuperview];
}

- (IBAction)cmdSignUp:(id)sender {
    //  [self addOTP];
    [self resignKeyBoard];
    NSString *strMobNum=[self.txtMobleNo.text stringByReplacingOccurrencesOfString:@" " withString:@""];
    if(strMobNum.length==10){
        
        [self sendMobileNum];
    }else if(strMobNum.length>10){
        [AlertView showAlertWithMessage:@"Enter a 10-Digit Mobile Number." view:self];
        
    }else{
         [AlertView showAlertWithMessage:@"Enter a 10-Digit Mobile Number." view:self];
    }
}
-(BOOL )showBaseMenu{
    return YES;
}


-(void)cancelNumberPad{
    doneCancleKeyBoard=NO;
    self.txtMobleNo.text=@"";
    [self resignKeyBoard];
}
-(void)doneWithNumberPad{
    doneCancleKeyBoard=NO;
    [self resignKeyBoard];
}

-(void)sendMobileNum{
    // [FIRAuth auth].languageCode = @"in";
    NSMutableDictionary *dict = [NSMutableDictionary new];
    [dict setObject:self.txtMobleNo.text forKey:@"mobile"];
    [self.view addSubview:ind];
    NSUserDefaults *prefs = [NSUserDefaults standardUserDefaults];
    NSString *countryCode= [prefs objectForKey:@"countryCode"];
    
    
    
    [[FIRPhoneAuthProvider provider] verifyPhoneNumber:[NSString stringWithFormat:@"%@%@",countryCode,self.txtMobleNo.text]
                                            UIDelegate:nil
                                            completion:^(NSString * _Nullable verificationID, NSError * _Nullable error) {
                                                // Dispatch asynchronously on the main thread as a temporary workaround to a known issue.
                                                dispatch_async(dispatch_get_main_queue(), ^() {
                                                    if (error) {
                                                        [ind removeFromSuperview];
                                                        [AlertView showAlertWithMessage:error.localizedDescription view:self];
                                                        //[self showMessagePrompt:error.localizedDescription];
                                                        return;
                                                    }
                                                    // Sign in using the verificationID and the code sent to the user.
                                                    // ...
                                                    [ind removeFromSuperview];
                                                    NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
                                                    [defaults setObject:verificationID forKey:@"authVerificationID"];
                                                    
                                                    OTPViewController* controller = [[OTPViewController alloc] initWithNibName:@"OTPViewController" bundle:nil];
                                                    controller.dictData=dict;
                                                    [self.navigationController pushViewController:controller animated:YES];
                                                    
                                                });
                                            }];
}

#pragma mark ---------- Text Feild delegate ------------

- (BOOL)textFieldShouldBeginEditing:(UITextField *)textField{
    NSLog(@"textFieldShouldBeginEditing");
    doneCancleKeyBoard=YES;
    return YES;
}

- (void)textFieldDidBeginEditing:(UITextField *)textField{
    NSLog(@"textFieldDidBeginEditing");
}

- (BOOL)textFieldShouldEndEditing:(UITextField *)textField{
    NSLog(@"textFieldShouldEndEditing");
    return YES;
}

- (void)textFieldDidEndEditing:(UITextField *)textField{
    NSLog(@"textFieldDidEndEditing");
}

- (BOOL)textField:(UITextField *)textField shouldChangeCharactersInRange:(NSRange)range replacementString:(NSString *)string{
    NSLog(@"textField:shouldChangeCharactersInRange:replacementString:");
    // Prevent invalid character input, if keyboard is numberpad
    if (textField.keyboardType == UIKeyboardTypeNumberPad)
    {
        if ([string rangeOfCharacterFromSet:[[NSCharacterSet decimalDigitCharacterSet] invertedSet]].location != NSNotFound)
        {
            
            
            return NO;
        }
    }
    
    return YES;
}

- (BOOL)textFieldShouldClear:(UITextField *)textField{
    NSLog(@"textFieldShouldClear:");
    return YES;
}

- (BOOL)textFieldShouldReturn:(UITextField *)textField{
    [self resignKeyBoard];
    [textField resignFirstResponder];
    return YES;
}


#pragma mark keyboardWillShow hide
- (void)keyboardWillShow:(NSNotification*)notification{
    CGSize keyboardSize = [[[notification userInfo] objectForKey:UIKeyboardFrameBeginUserInfoKey] CGRectValue].size;
    [UIView animateWithDuration:0.4
                          delay:0.0
                        options: UIViewAnimationOptionCurveEaseInOut
                     animations:^{
                         
                         if([notification.name isEqualToString:@"UIKeyboardWillShowNotification"]){
                             self.view.frame=CGRectMake(self.view.frame.origin.x, -100, self.view.frame.size.width, self.view.frame.size.height);
                         }else{
                             self.view.frame=CGRectMake(self.view.frame.origin.x, 0, self.view.frame.size.width, self.view.frame.size.height);
                         }
                         
                     }
                     completion:^(BOOL finished){
                         NSLog(@"Done!");
                     }];
}
-(void)resignKeyBoard{
    doneCancleKeyBoard=NO;
    [self.txtMobleNo resignFirstResponder];
}

- (IBAction)cmdSkipVerfication:(id)sender {
   self.sidePanelController.centerPanel = [[SupportClass getNavigationController] initWithRootViewController:[[SupportClass getStoryBorad] instantiateViewControllerWithIdentifier:@"HomeViewController"]];

}
#pragma mark - Country Code

- (NSDictionary *)getCountryCodeDictionary {
    return [NSDictionary dictionaryWithObjectsAndKeys:@"972", @"IL",
            @"93", @"AF", @"355", @"AL", @"213", @"DZ", @"1", @"AS",
            @"376", @"AD", @"244", @"AO", @"1", @"AI", @"1", @"AG",
            @"54", @"AR", @"374", @"AM", @"297", @"AW", @"61", @"AU",
            @"43", @"AT", @"994", @"AZ", @"1", @"BS", @"973", @"BH",
            @"880", @"BD", @"1", @"BB", @"375", @"BY", @"32", @"BE",
            @"501", @"BZ", @"229", @"BJ", @"1", @"BM", @"975", @"BT",
            @"387", @"BA", @"267", @"BW", @"55", @"BR", @"246", @"IO",
            @"359", @"BG", @"226", @"BF", @"257", @"BI", @"855", @"KH",
            @"237", @"CM", @"1", @"CA", @"238", @"CV", @"345", @"KY",
            @"236", @"CF", @"235", @"TD", @"56", @"CL", @"86", @"CN",
            @"61", @"CX", @"57", @"CO", @"269", @"KM", @"242", @"CG",
            @"682", @"CK", @"506", @"CR", @"385", @"HR", @"53", @"CU",
            @"537", @"CY", @"420", @"CZ", @"45", @"DK", @"253", @"DJ",
            @"1", @"DM", @"1", @"DO", @"593", @"EC", @"20", @"EG",
            @"503", @"SV", @"240", @"GQ", @"291", @"ER", @"372", @"EE",
            @"251", @"ET", @"298", @"FO", @"679", @"FJ", @"358", @"FI",
            @"33", @"FR", @"594", @"GF", @"689", @"PF", @"241", @"GA",
            @"220", @"GM", @"995", @"GE", @"49", @"DE", @"233", @"GH",
            @"350", @"GI", @"30", @"GR", @"299", @"GL", @"1", @"GD",
            @"590", @"GP", @"1", @"GU", @"502", @"GT", @"224", @"GN",
            @"245", @"GW", @"595", @"GY", @"509", @"HT", @"504", @"HN",
            @"36", @"HU", @"354", @"IS", @"91", @"IN", @"62", @"ID",
            @"964", @"IQ", @"353", @"IE", @"972", @"IL", @"39", @"IT",
            @"1", @"JM", @"81", @"JP", @"962", @"JO", @"77", @"KZ",
            @"254", @"KE", @"686", @"KI", @"965", @"KW", @"996", @"KG",
            @"371", @"LV", @"961", @"LB", @"266", @"LS", @"231", @"LR",
            @"423", @"LI", @"370", @"LT", @"352", @"LU", @"261", @"MG",
            @"265", @"MW", @"60", @"MY", @"960", @"MV", @"223", @"ML",
            @"356", @"MT", @"692", @"MH", @"596", @"MQ", @"222", @"MR",
            @"230", @"MU", @"262", @"YT", @"52", @"MX", @"377", @"MC",
            @"976", @"MN", @"382", @"ME", @"1", @"MS", @"212", @"MA",
            @"95", @"MM", @"264", @"NA", @"674", @"NR", @"977", @"NP",
            @"31", @"NL", @"599", @"AN", @"687", @"NC", @"64", @"NZ",
            @"505", @"NI", @"227", @"NE", @"234", @"NG", @"683", @"NU",
            @"672", @"NF", @"1", @"MP", @"47", @"NO", @"968", @"OM",
            @"92", @"PK", @"680", @"PW", @"507", @"PA", @"675", @"PG",
            @"595", @"PY", @"51", @"PE", @"63", @"PH", @"48", @"PL",
            @"351", @"PT", @"1", @"PR", @"974", @"QA", @"40", @"RO",
            @"250", @"RW", @"685", @"WS", @"378", @"SM", @"966", @"SA",
            @"221", @"SN", @"381", @"RS", @"248", @"SC", @"232", @"SL",
            @"65", @"SG", @"421", @"SK", @"386", @"SI", @"677", @"SB",
            @"27", @"ZA", @"500", @"GS", @"34", @"ES", @"94", @"LK",
            @"249", @"SD", @"597", @"SR", @"268", @"SZ", @"46", @"SE",
            @"41", @"CH", @"992", @"TJ", @"66", @"TH", @"228", @"TG",
            @"690", @"TK", @"676", @"TO", @"1", @"TT", @"216", @"TN",
            @"90", @"TR", @"993", @"TM", @"1", @"TC", @"688", @"TV",
            @"256", @"UG", @"380", @"UA", @"971", @"AE", @"44", @"GB",
            @"1", @"US", @"598", @"UY", @"998", @"UZ", @"678", @"VU",
            @"681", @"WF", @"967", @"YE", @"260", @"ZM", @"263", @"ZW",
            @"591", @"BO", @"673", @"BN", @"61", @"CC", @"243", @"CD",
            @"225", @"CI", @"500", @"FK", @"44", @"GG", @"379", @"VA",
            @"852", @"HK", @"98", @"IR", @"44", @"IM", @"44", @"JE",
            @"850", @"KP", @"82", @"KR", @"856", @"LA", @"218", @"LY",
            @"853", @"MO", @"389", @"MK", @"691", @"FM", @"373", @"MD",
            @"258", @"MZ", @"970", @"PS", @"872", @"PN", @"262", @"RE",
            @"7", @"RU", @"590", @"BL", @"290", @"SH", @"1", @"KN",
            @"1", @"LC", @"590", @"MF", @"508", @"PM", @"1", @"VC",
            @"239", @"ST", @"252", @"SO", @"47", @"SJ", @"963", @"SY",
            @"886", @"TW", @"255", @"TZ", @"670", @"TL", @"58", @"VE",
            @"84", @"VN", @"1", @"VG", @"1", @"VI", nil];
}

-(IBAction)cmdSelectCountry:(id)sender {
    CountryListViewController *cv = [[CountryListViewController alloc] initWithNibName:@"CountryListViewController" delegate:self];
    [self presentViewController:cv animated:YES completion:NULL];
}
- (void)didSelectCountry:(NSDictionary *)country
{
    NSString *countryCode=[country objectForKey:@"dial_code"];
    NSString *name=[country objectForKey:@"name"];
    name=[NSString stringWithFormat:@"%@ %@",[country objectForKey:@"dial_code"],[country objectForKey:@"code"]];
    [_btnSelectCountry setTitle:name forState:UIControlStateNormal];
    NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
    [defaults setObject:countryCode forKey:@"countryCode"];
    [defaults setObject:name forKey:@"name"];
    [defaults synchronize];
    NSLog(@"%@", country);
}
@end
