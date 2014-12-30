//
//  JHListView.h
//  Artist
//
//  Created by Sean Grusd on 1/20/13.
//  Copyright (c) 2013 Sean Grusd. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface JHListView : UIViewController <UITableViewDataSource, UITableViewDelegate, UISearchBarDelegate> {
    
    IBOutlet UITableView * listTableView;
    IBOutlet UISearchBar * m_searchBar;
    
    NSArray * artistList;
}

@end
