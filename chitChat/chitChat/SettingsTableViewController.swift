//
//  SettingsTableViewController.swift
//  chitChat
//
//  Created by Emmet Susslin on 7/14/16.
//  Copyright © 2016 Emmet Susslin. All rights reserved.
//

import UIKit

class SettingsTableViewController: UITableViewController, UINavigationControllerDelegate, UIImagePickerControllerDelegate {

    
    @IBOutlet weak var HeaderView: UIView!
    
    @IBOutlet weak var imageUser: UIImageView!
    
    @IBOutlet weak var userNameLabel: UILabel!
    
    
    @IBOutlet weak var avatarSwitch: UISwitch!
    @IBOutlet weak var avatarCell: UITableViewCell!
    @IBOutlet weak var termsCell: UITableViewCell!
    @IBOutlet weak var privacyCell: UITableViewCell!
    @IBOutlet weak var logOutCell: UITableViewCell!
    
    var avatarSwitchStatus = true
    let userDefaults = NSUserDefaults.standardUserDefaults()
    var firstLoad: Bool?
    
    override func viewDidLoad() {
        super.viewDidLoad()

        self.tableView.tableHeaderView = HeaderView
        
        imageUser.layer.cornerRadius = imageUser.frame.size.width / 2
        imageUser.layer.masksToBounds = true
        
        loadUserDefaults()
        updateUI()
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    //MARK: IBActions
    
    @IBAction func didClickAvatarImage(sender: UIButton) {
        changePhoto()
        
        
    }
    
    @IBAction func avatarSwitchValueChanged(switchState: UISwitch) {
        
        if switchState.on {
            avatarSwitchStatus = true
        } else {
            avatarSwitchStatus = false
            print("it off")
        }
        
        saveUserDefaults()
    }
    

    // MARK: - Table view data source

    override func numberOfSectionsInTableView(tableView: UITableView) -> Int {
        
        return 2
    }

    override func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        
        if section == 0 { return 3 }
        if section == 1 { return 1 }
        return 0
    }

   
    override func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        
        if ((indexPath.section == 0) && (indexPath.row == 0)) { return privacyCell }
        if ((indexPath.section == 0) && (indexPath.row == 1)) { return termsCell }
        if ((indexPath.section == 0) && (indexPath.row == 2)) { return avatarCell }
        if ((indexPath.section == 1) && (indexPath.row == 0)) { return logOutCell }

        // Configure the cell...

        return UITableViewCell()
    }
 

    override func tableView(tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        
        if section == 0 {
            return 0
        } else {
            return 25.0
        }
        return 0
    }
    
    override func tableView(tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        let headerView = UIView()
        headerView.backgroundColor = UIColor.clearColor()
        
        return headerView
    }
    
    //MARK: tableview delegate functions
    
    override func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        if indexPath.section == 1 && indexPath.row == 0 {
            showLogoutView()
        }
    }
    
    //MARK: Change pic
    
    func changePhoto() {
        
        let camera = Camera(delegate_: self)
        
        let optionMenu = UIAlertController(title: nil, message: nil, preferredStyle: .ActionSheet)
        
        let takePhoto = UIAlertAction(title: "Take Photo", style: .Default) { (alert: UIAlertAction!) -> Void in
         
            camera.PresentPhotoCamera(self, canEdit: true)
        }
        
        let sharePhoto = UIAlertAction(title: "Photo Library", style: .Default) { (alert: UIAlertAction!) -> Void in
            camera.PresentPhotoLibrary(self, canEdit: true)
        }
        
        let cancelAction = UIAlertAction(title: "Cancel", style: .Cancel) { (alert: UIAlertAction!) -> Void in
         print("Cancel")
        }
        
        optionMenu.addAction(takePhoto)
        optionMenu.addAction(sharePhoto)
        optionMenu.addAction(cancelAction)
        
        self.presentViewController(optionMenu, animated: true, completion: nil)
        
    }
    
    //MARK: UIImagePickerControllerDelegate functions
    
    func imagePickerController(picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [String : AnyObject]) {
        
        let image = info[UIImagePickerControllerEditedImage] as! UIImage
        
        uploadAvatar(image) { (imageLink) -> Void in
            
            let properties = ["Avatar" : imageLink!]
            
            currentUser!.updateProperties(properties)
            
            backendless.userService.update(currentUser, response: { (updatedUser: BackendlessUser!) -> Void in
                
                print("updated current user \(updatedUser)")
                
                
                }, error: { (fault : Fault!) -> Void in
                    print("error: \(fault)")
            })
        
        }
        picker.dismissViewControllerAnimated(true, completion: nil)
    }
    
    //MARK: Update UI
    
    func updateUI() {
        
        userNameLabel.text = currentUser.name
        
        avatarSwitch.setOn(avatarSwitchStatus, animated: false)
        
        if let imageLink = currentUser.getProperty("Avatar") {
            getImageFromURL(imageLink as! String, result: { (image) -> Void in
                self.imageUser.image = image
            })
        }
    }
    
    //MARK: Helper functions
    
    func showLogoutView() {
        
        let optionMenu = UIAlertController(title: nil, message: nil, preferredStyle: .ActionSheet)
        
        let logoutAction = UIAlertAction(title: "Log Out", style: .Destructive) { (alert: UIAlertAction!) -> Void in
            self.logOut()
        }
        
        let cancelAction = UIAlertAction(title: "Cancel", style: .Cancel) { (alert: UIAlertAction!) -> Void in
         print("cancelled")
        }
        
        optionMenu.addAction(logoutAction)
        optionMenu.addAction(cancelAction)
        self.presentViewController(optionMenu, animated: true, completion: nil)
    }
    
    func logOut() {
        backendless.userService.logout()
        
        let loginView = storyboard!.instantiateViewControllerWithIdentifier("LoginView")
        self.presentViewController(loginView, animated: true, completion: nil)
    }
    
    //MARK: UserDefaults
    
    func saveUserDefaults() {
        userDefaults.setBool(avatarSwitchStatus, forKey: kAVATARSTATE)
        userDefaults.synchronize()
        
    }
    
    func loadUserDefaults() {
        firstLoad = userDefaults.boolForKey(kFIRSTRUN)
        
        if !firstLoad! {
            userDefaults.setBool(true, forKey: kFIRSTRUN)
            userDefaults.setBool(avatarSwitchStatus, forKey: kAVATARSTATE)
            userDefaults.synchronize()
        }
        
        avatarSwitchStatus = userDefaults.boolForKey(kAVATARSTATE)
        
    }

}
