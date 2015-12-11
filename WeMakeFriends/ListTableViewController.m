//
//  ListTableViewController.m
//  WeMakeFriends
//
//  Created by Oslo on 10/27/15.
//  Copyright © 2015 Shih Chi Lin. All rights reserved.
//

#import "ListTableViewController.h"

@interface ListTableViewController () <UserProtocol, CategoryProtocol>

@property (strong, nonatomic) DatabaseManager *dbManager;
@property (strong, nonatomic) NSArray *dataArray;
@property NSString *currentCategory;

-(void) loadData;

@end

@implementation ListTableViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    // Uncomment the following line to preserve selection between presentations.
    // self.clearsSelectionOnViewWillAppear = NO;
    UIImage *image = [UIImage imageNamed:@"beach.png"];
    self.parentViewController.view.backgroundColor = [UIColor colorWithPatternImage:image];
    self.tableView.backgroundColor = [UIColor clearColor];
    self.tableView.alpha = 0.4f;
    // Uncomment the following line to display an Edit button in the navigation bar for this view controller.
    // self.navigationItem.rightBarButtonItem = self.editButtonItem;
    self.dbManager = [[DatabaseManager alloc] initWithDatabaseFilename:@"hottinder.sql"];
    // query the data out
    [self loadData];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

-(void)viewDidAppear:(BOOL)animated {
    [super viewDidAppear:animated];
    // load data
    [self getUserInfo];
    [self.tableView reloadData];
}

-(void)loadData {
    // the select statement to query all the data from the table
    // create the select sql statement to query data from the database
    NSString *querySelect = [NSString stringWithFormat:@"select * from Users where name='%@'", self.currentUser.name];
    // make sure the data array is empty(nil)
    if (self.dataArray != nil) {
        self.dataArray = nil;
    }
    // load data from the database table
    self.dataArray = [[NSArray alloc] initWithArray:[_dbManager loadDatafromDB:querySelect]];
}

-(void) getUserInfo {
    NSString *querySelect = [NSString stringWithFormat:@"select * from Users where name='%@'", self.currentUser.name];
    // self dataArray already has data
    self.dataArray = [_dbManager loadDatafromDB:querySelect];
}

// the delegate method from EditProfileVC
// implement the method of getting data from the forwarding view controller
-(void)sendBackUserData:(Users *)receivedUser withImage:(UserImage *)receivedImage{
    // check the important fields that they are not empty
    if ((receivedUser.username.length != 0) && (receivedUser.email.length != 0) && (![receivedUser.todo isEqualToString:@""])) {
        // receive all the data from the call back User
        self.currentUser.username = receivedUser.username;
        self.currentUser.email = receivedUser.email;
        self.currentUser.todo = receivedUser.todo;
        self.currentUser.phone = receivedUser.phone;
        self.currentUser.facebook = receivedUser.facebook;
    }
    self.currentImage = receivedImage;
}

#pragma mark - Table view data source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
//#warning Incomplete implementation, return the number of sections
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
//#warning Incomplete implementation, return the number of rows
    return 3;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    
    NSString *editProfile = @"editProfile";
    NSString *searchFriend = @"searchFriend";
    NSString *chooseCategory = @"chooseCategory";
    
    // create two different type of cell to prepare to assign
    // UITableViewCell *cell = [[UITableViewCell alloc] init];
    if ( indexPath.row == 0 ) {
        UITableViewCell *cell1 = [tableView dequeueReusableCellWithIdentifier:editProfile forIndexPath:indexPath];
        cell1.textLabel.text = editProfile;
        if (self.currentUser.name != nil) {

            //cell1.detailTextLabel.text = [displayUser stringByAppendingString:self.currentUser.name];
            // fetch the data from the sqlite database, set the subtitle of the tableview cell as "user: " + the login name from the parent view controller
            NSInteger indexOfName = [self.dbManager.columnNames indexOfObject:@"name"];
            NSString *indexName = [NSString stringWithFormat:@"%@",[[self.dataArray objectAtIndex:indexPath.row] objectAtIndex:indexOfName]];
            NSString *displayUser = @"user: ";
            cell1.detailTextLabel.text = [displayUser stringByAppendingString:indexName];
        } else {

            // it's the case that user didn't log into database but just insert data into the form
            // then we display the username, not the real name
            if (self.currentUser.username != nil ) {
                if (self.currentUser.username.length != 0) {
                    NSString *tempUser = @"user: ";
                    cell1.detailTextLabel.text = [tempUser stringByAppendingString:self.currentUser.username];
                } else {
                    cell1.detailTextLabel.text = @"unknown user";
                }
            } else {
                cell1.detailTextLabel.text = @"unknown user";
            }
        }
        return cell1;
    } else if (indexPath.row == 1){
        UITableViewCell *cell2 = [tableView dequeueReusableCellWithIdentifier:searchFriend forIndexPath:indexPath];
        cell2.textLabel.text = searchFriend;
        return cell2;
    } else {
        UITableViewCell *cell3 = [tableView dequeueReusableCellWithIdentifier:chooseCategory forIndexPath:indexPath];
        cell3.textLabel.text = chooseCategory;
        if (self.currentCategory.length == 0) {
            cell3.detailTextLabel.text = @"unknown";
        } else {
            cell3.detailTextLabel.text = self.currentCategory;
        }
        return cell3;
    }
    
}

-(void)getCategory:(NSString *)category {
    self.currentCategory = category;
}


/*
// Override to support conditional editing of the table view.
- (BOOL)tableView:(UITableView *)tableView canEditRowAtIndexPath:(NSIndexPath *)indexPath {
    // Return NO if you do not want the specified item to be editable.
    return YES;
}
*/

/*
// Override to support editing the table view.
- (void)tableView:(UITableView *)tableView commitEditingStyle:(UITableViewCellEditingStyle)editingStyle forRowAtIndexPath:(NSIndexPath *)indexPath {
    if (editingStyle == UITableViewCellEditingStyleDelete) {
        // Delete the row from the data source
        [tableView deleteRowsAtIndexPaths:@[indexPath] withRowAnimation:UITableViewRowAnimationFade];
    } else if (editingStyle == UITableViewCellEditingStyleInsert) {
        // Create a new instance of the appropriate class, insert it into the array, and add a new row to the table view
    }   
}
*/

/*
// Override to support rearranging the table view.
- (void)tableView:(UITableView *)tableView moveRowAtIndexPath:(NSIndexPath *)fromIndexPath toIndexPath:(NSIndexPath *)toIndexPath {
}
*/

/*
// Override to support conditional rearranging of the table view.
- (BOOL)tableView:(UITableView *)tableView canMoveRowAtIndexPath:(NSIndexPath *)indexPath {
    // Return NO if you do not want the item to be re-orderable.
    return YES;
}
*/

#pragma mark - Navigation

-(BOOL)shouldPerformSegueWithIdentifier:(NSString *)identifier sender:(id)sender {
    if ([identifier isEqualToString:@"searchFriend"]) {
        if (self.currentUser.username.length == 0 || self.currentUser.email.length == 0 || self.currentUser.todo.length == 0) {
            UIAlertController *alert = [UIAlertController alertControllerWithTitle:@"Warning !" message:@"user data is empty" preferredStyle:UIAlertControllerStyleAlert];
            UIAlertAction *action = [UIAlertAction actionWithTitle:@"Go back re-enter" style:UIAlertActionStyleDefault handler:^(UIAlertAction *action1){}];
            [alert addAction:action];
            [self presentViewController:alert animated:YES completion:nil];
            return NO;
        }
    }
    return YES;
}

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
    
    // decide which segue and what data is going to be passed
    if ([segue.identifier isEqualToString:@"editProfile"]) {
        EditProfileViewController *editUser = [segue destinationViewController];
        editUser.currentUser = self.currentUser;
        editUser.currentImage = self.currentImage;
        // assign your class itself as the delegate of the forwarding view controller, so that you can implement the delegate methods
        editUser.myDelegate = self;
        // pass data to the new view controller
    } else if ([segue.identifier isEqualToString:@"searchFriend"]) {
        FriendViewController *lookForFriends = [segue destinationViewController];
        lookForFriends.currentUser = self.currentUser;
        lookForFriends.currentImage = self.currentImage;
        lookForFriends.currentCategory = self.currentCategory;
    } else if ([segue.identifier isEqualToString:@"chooseCategory"]) {
        CategoryTableViewController *categoryVC = [segue destinationViewController];
        categoryVC.myDelegate = self;
        
    }
}


@end
