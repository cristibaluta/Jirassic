//
//  JLPredictiveTimeTyping.swift
//  Jira-Logger
//
//  Created by Baluta Cristian on 06/05/15.
//  Copyright (c) 2015 Cristian Baluta. All rights reserved.
//

import Cocoa

class JLPredictiveTimeTyping: NSObject {

    func timeByAdding(string: String) -> String {
	//- (BOOL)textField:(UITextField *)textField shouldChangeCharactersInRange:(NSRange)range replacementString:(NSString *)string {
	
        if (string == "") {
            // Backspace
            if (textField.text.length == 3) {
                textField.text = [textField.text substringWithRange:NSMakeRange(0,1)];
                return false
            }
            return  true
        }
	
        NSArray *comps = [textField.text componentsSeparatedByString:@":"];
        
        if ([comps count] == 2) {
        // Insert the minutes
        
        int m;
        NSString *min = [comps objectAtIndex:1];
        
        if (min.length >= 2) {
        textField.text = [NSString stringWithFormat:@"%@:%@", [comps objectAtIndex:0], [min substringWithRange:NSMakeRange(0,1)]];
        return YES;
        }
        else {
        m = [self decimalValueOf:min newText:string];
        }
        
        if (m >= 60) {
        return NO;
        }
        else if (m >= 10) {
        return YES;
        }
        else if (m >= 6) {
        textField.text = [NSString stringWithFormat:@"%@:0%d", comps[0], m];
        }
        else if (m == 0) {
        textField.text = [NSString stringWithFormat:@"%@:00", comps[0]];
        }
        else if (m == 1) {
        textField.text = [NSString stringWithFormat:@"%@:15", comps[0]];
        }
        else if (m == 2) {
        textField.text = [NSString stringWithFormat:@"%@:20", comps[0]];
        }
        else if (m == 3) {
        textField.text = [NSString stringWithFormat:@"%@:30", comps[0]];
        }
        else if (m == 4) {
        textField.text = [NSString stringWithFormat:@"%@:45", comps[0]];
        }
        else if (m == 5) {
        textField.text = [NSString stringWithFormat:@"%@:50", comps[0]];
        }
        else return YES;
        return NO;
        }
        else {
        // Insert the hour
        NSString *hr = [comps objectAtIndex:0];
        int h = [self decimalValueOf:hr newText:string];
        
        if (h >= 24) {
        textField.text = @"00:";
        }
        else if (h >= 10) {
        // Do not perform any edit on this hour
        textField.text = [NSString stringWithFormat:@"%d:", h];
        }
        else if (h >= 3) {
        textField.text = [NSString stringWithFormat:@"0%d:", h];
        }
        else {
        if (hr.length >= 1) {
        textField.text = [NSString stringWithFormat:@"0%d:", h];
        }
        else {
        return YES;
        }
        }
        return NO;
        }
        
        return YES;
	}
	
    func dateFromString (string: String) -> NSDate {
	
        let gregorian = NSCalendar(calendarIdentifier: NSCalendarIdentifierGregorian)
        let comps = gregorian!.components( NSCalendarUnit.CalendarUnitHour | NSCalendarUnit.CalendarUnitMinute | NSCalendarUnit.CalendarUnitSecond, fromDate: NSDate())
        
        let hm = string.componentsSeparatedByString(":")
        
        if (hm.count > 1) {
            comps.hour = hm[0].intValue()
            comps.minute = hm[1].intValue()
        }
        else {
            comps.hour = (hm.count == 1) ? hm[0].integerValue() : 19;
            comps.minute = 0
        }
        NSUserDefaults.standardUserDefaults().setInteger(hm[0].integerValue(), forKey:KEY_LAST_TYPED_HOUR)
        NSUserDefaults.standardUserDefaults().synchronize()
        
        return [gregorian dateFromComponents:comps];
    }
        
    - (int)decimalValueOf:(NSString *)existingText newText:(NSString *)newText {
        
        if ([existingText length] > 0) {
        int i1 = [existingText intValue];
        int i2 = [newText intValue];
        return i1 * 10 + i2;
        }
        return [newText intValue];
	}
}
