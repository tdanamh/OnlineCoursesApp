//  CourseTableViewController.swift
//  Proiect1
//  Created by Dana Tudor on 03/05/2020.
//  Copyright © 2020 Dana Tudor. All rights reserved.

import UIKit
import FirebaseDatabase
import FirebaseAuth
import FirebaseStorage

class CourseTableViewController: UITableViewController {
    
    //MARK: Properties
    
    @IBOutlet weak var addButton: UIBarButtonItem!
    
    var courses = [Course]()
    
    let ref = Database.database().reference()
    let storage = Storage.storage()
    
    var teacherKey = ""
    var databaseKey = ""
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // Use the edit button item provided by the table view controller.
        navigationItem.leftBarButtonItem = editButtonItem
        
        loadCourses()
        
        _ = Auth.auth().currentUser?.email

        // Get key from firebase
        ref.observeSingleEvent(of: .value, with: { (snapshot) in
            // Get user value
            let value = snapshot.value as? NSDictionary
            self.databaseKey = value?["teacherKey"] as? String ?? ""
            // Hide button + if not teacher
            if self.teacherKey != self.databaseKey || self.teacherKey == ""{
                self.addButton.isEnabled = false
            }
          }) { (error) in
            print(error.localizedDescription)
            }
    }

    override func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return courses.count
    }

    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        // Table view cells are reused and should be dequeued using a cell identifier.
        let cellIdentifier = "CourseTableViewCell"
        
        guard let cell = tableView.dequeueReusableCell(withIdentifier: cellIdentifier, for: indexPath) as? CourseTableViewCell else {
            fatalError("The dequeued cell is not an instance of CourseTableViewCell.")
        }
        
        // Fetches the appropriate course for the data source layout.
        let course = courses[indexPath.row]
        
        // Configure the cell...
        cell.nameLabel.text = course.name
        cell.photoImageView.image = UIImage(named: "courseImage")
        // Set cell's button accesibilityLabel to index of course in order to save the index of the chosen cell
        cell.viewCourseButton.accessibilityLabel = course.index
        
        // Get key from Firebase
        ref.observeSingleEvent(of: .value, with: { (snapshot) in
            let value = snapshot.value as? NSDictionary
            self.databaseKey = value?["teacherKey"] as? String ?? ""
            // Disable edit button if not a teacher
            if (self.databaseKey != self.teacherKey) || self.teacherKey == "" {
                cell.editButton.isEnabled = false
            }
          }) { (error) in
            print(error.localizedDescription)
            }
        return cell
    }
    
    override func tableView(_ tableView: UITableView, canEditRowAt indexPath: IndexPath) -> Bool {
        if (self.databaseKey != self.teacherKey) || self.teacherKey == "" {
            return false
        }
        return true
    }
    
    // Override to support editing the table view.
    override func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCell.EditingStyle, forRowAt indexPath: IndexPath) {
        
        if editingStyle == .delete {
            let course = courses[indexPath.row]
            let index = course.index
            // Delete in Firebase when deleting
            let postRef = self.ref.child("courses")
            postRef.child(index).removeValue()
        } else if editingStyle == .insert {
            //
        }    
    }

    // MARK: - Navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        
        super.prepare(for: segue, sender: sender)
        
        switch(segue.identifier ?? "") {
            
            case "AddItem":
            print("Adding a new course.")
            
            
            case "ShowDetail":  // Edit a course
            guard let detailViewController = segue.destination as? ViewController else {
                fatalError("Unexpected destination: \(segue.destination)")
            }
             
            guard let selectedCourseCellButton = sender as? UIButton else {
                fatalError("Unexpected sender: \(String(describing: sender))")
            }
            
            let id = selectedCourseCellButton.accessibilityLabel
            let course = self.courses.filter{$0.index == id}.first
            let indexOfArray = self.courses.firstIndex(of: course!)
            let myIndexPath = IndexPath(row: indexOfArray!, section: 0)
            let selectedCourse = courses[indexOfArray!]
            
            tableView.selectRow(at: myIndexPath, animated: true, scrollPosition:UITableView.ScrollPosition.middle)

            detailViewController.course = selectedCourse
            
            
            case "viewCourse":  // View a course
            guard let viewCourseViewController = segue.destination as? ViewCourseViewController else {
                fatalError("Unexpected destination: \(segue.destination)")
            }
            
            guard let selectedCourseCell = sender as? CourseTableViewCell else {
                fatalError("Unexpected sender: \(String(describing: sender))")
            }
             
            guard let indexPath = tableView.indexPath(for: selectedCourseCell) else {
                fatalError("The selected cell is not being displayed by the table")
            }
             
            let selectedCourse = courses[indexPath.row]
            viewCourseViewController.course = selectedCourse
            
            default:
                fatalError("Unexpected Segue Identifier; \(String(describing: segue.identifier))")
        }
    }
    
    //MARK: Actions
    @IBAction func unwindToCourseList(sender: UIStoryboardSegue) {
        if let sourceViewController = sender.source as? ViewController, let course = sourceViewController.course {
            let courseIndex = course.index
            let courseContent = course.courseContent
            let courseName = course.name
            let coursePhoto = course.coursePhoto
            
            let postRef = self.ref.child("courses")
            let key = postRef.childByAutoId().key!

            let storage = Storage.storage()
            let storageRef = storage.reference()
            
            let photo = coursePhoto?.pngData()
            
            let riversRef = storageRef.child("images/\(key).png")
            
            // UPDATE an existing course.
            if let selectedIndexPath = tableView.indexPathForSelectedRow {
                // Save photo in Firebase Storage
                _ = riversRef.putData(photo!, metadata: nil) { (metadata, error) in
                    guard let metadata = metadata else {
                       print("An error occured")
                       return
                    }
                    // Metadata contains file metadata such as size, content-type.
                    _ = metadata.size
                    // Download photo from Firebase Storage
                    riversRef.downloadURL { (url, error) in
                        guard url != nil else {
                            print("An error occured")
                            return
                        }
                        // Update the course in Firebase Database
                        _ = self.ref.child("courses/\(courseIndex)/content").setValue(courseContent)
                        _ = self.ref.child("courses/\(courseIndex)/name").setValue(courseName)
                                       
                        self.courses[selectedIndexPath.row] = course
                        self.tableView.reloadRows(at: [selectedIndexPath], with: .none)
                    }
                }
            }
            else { // SAVE a new course
                // Save photo in Firebase Storage
                _ = riversRef.putData(photo!, metadata: nil) { (metadata, error) in
                    guard let metadata = metadata else {
                        print("An error occured")
                        return
                    }
                    // Metadata contains file metadata such as size, content-type.
                    _ = metadata.size
                    // Download photo from Firebase Storage
                    riversRef.downloadURL { (url, error) in
                        guard url != nil else {
                            print("An error occured")
                            return
                        }
                    // Save new course
                    postRef.child(key).setValue(["content": courseContent, "index": key, "name": courseName])
                  }
                }
            }
        }
    }
         
    private func loadCourses() {
        
        let postRef = self.ref.child("courses")
        
        // Listen for new courses in the Firebase database
        postRef.observe(.childAdded, with: { (snapshot) -> Void in
            let courseData = snapshot.value as? [String: AnyObject] ?? [:]
            
            let name = courseData["name"] as! String
            let courseContent = courseData["content"] as! String
            let index = courseData["index"] as! String
            
            var coursePhoto: UIImage?
            let storage = Storage.storage()
            let pathReference = storage.reference(withPath: "images/\(index).png")
            
            // Download photo from Fibrease Storage
            pathReference.getData(maxSize: 1 * 10000 * 10000) { data, error in
                if let error = error {
                    print(error.localizedDescription)
                    fatalError("Unable to get data")
                } else {
                    coursePhoto = UIImage(data: data!)
                    guard let course = Course(name: name, coursePhoto: coursePhoto, courseContent: courseContent, index: index) else {
                        fatalError("Unable to instantiate course")
                    }
                // Append new course to array and insert in table view
                self.courses.append(course)
                self.tableView.insertRows(at: [IndexPath(row: self.courses.count-1, section: 0)], with: UITableView.RowAnimation.automatic)
              }
            }
        })
        
        // Listen for deleted courses in the Firebase database
        postRef.observe(.childRemoved, with: { (snapshot) -> Void in
            let courseData = snapshot.value as? [String: AnyObject] ?? [:]
            
            let index = courseData["index"] as! String
            let course = self.courses.filter{$0.index == index}.first
            let id = self.courses.firstIndex(of: course!)

            self.courses.remove(at: id!)
            self.tableView.deleteRows(at: [IndexPath(row: id!, section: 0)], with: UITableView.RowAnimation.automatic)
        })

    }

}
