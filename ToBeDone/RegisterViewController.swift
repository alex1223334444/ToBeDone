//
//  RegisterViewController.swift
//  ToBeDone
//
//  Created by Udrea Alexandru-Iulian-Alberto on 31.10.2022.
//

import UIKit
import FirebaseAuth
import FirebaseCore


class RegisterViewController: UIViewController, TextFieldWithLabelDelegate, ButtonDelegate {
    func buttonTouchUpInside() {
        print(user)
        Auth.auth().createUser(withEmail: user.username, password: user.password) { [self] (authResult, error) in
          if let error = error {
            print(error.localizedDescription)
          } else {
              if let firebaseUser = authResult?.user{
                  let uid = firebaseUser.uid
                  let request : User = User(username: user.username, lastName: user.lastName, uid: uid, firstName: user.firstName)
                  print(request)
                  createUser(user: request) { result in
                      switch result {
                      case .success(_):
                          print("success")
                      case .failure(let error):
                          print(error)
                      }
                  }
              }
              
          }
        }
        do {
          try Auth.auth().signOut()
            print("user signed out")
        } catch let error {
          print(error.localizedDescription)
        }
        performSegue(withIdentifier: "tasks", sender: nil)
    }
    
    @IBOutlet weak var tableView: UITableView!
    private var user : UserModel = UserModel()
    private var labels : [String] = ["First name", "Last name","Username","Password","Confirm password"]
    private var buttonCell : ButtonCell?
    func changeText(_ textContent: UITextField?) {
        guard let text = textContent?.text else {
            return
        }
        switch textContent?.tag {
        case 0 :
            user.firstName = text
        case 1:
            user.lastName = text
        case 2:
            user.username = text
        case 3:
            user.password = text
        case 4:
            user.confirm = text
        default:
            print(user)
        }
        buttonCell?.enableButton(enabled: true)
    }
        
    override func viewDidLoad() {
        super.viewDidLoad()
        self.tableView.dataSource = self
        self.tableView.delegate = self
        tableView.layer.cornerRadius = 10
        self.hideKeyboardWhenTappedAround()
    }
    
}


extension RegisterViewController : UITableViewDataSource, UITableViewDelegate{
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return labels.count + 1
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        if indexPath.row < labels.count {
            guard let cell = tableView.dequeueReusableCell(withIdentifier: "textfield", for: indexPath) as? TextFieldWithLabelCell else {
                return UITableViewCell()
            }
            if indexPath.row == 3 || indexPath.row == 4
            {
                cell.configureTextFieldCell(labels[indexPath.row], tag: indexPath.row, secure: true, delegate : self)
            }
            else
            {
                cell.configureTextFieldCell(labels[indexPath.row], tag: indexPath.row, secure: false, delegate : self)
            }
            cell.showsReorderControl = true
            return cell
            
        }
        else {
            guard let cell = tableView.dequeueReusableCell(withIdentifier: "button", for: indexPath) as? ButtonCell else {
                return UITableViewCell()
            }
            cell.configureButton(title: "Submit", delegate: self)
            cell.showsReorderControl = true
            buttonCell = cell
            return cell
        }
    }
}


struct UserModel {
    var firstName : String = ""
    var lastName : String = ""
    var username : String = ""
    var password : String = ""
    var confirm : String = ""
}
