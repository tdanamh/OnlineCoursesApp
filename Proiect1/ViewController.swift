//  ViewController.swift
//  Proiect1
//  Created by Dana Tudor on 03/05/2020.
//  Copyright © 2020 Dana Tudor. All rights reserved.

import UIKit
import FirebaseDatabase

class ViewController: UIViewController, UITextFieldDelegate, UIImagePickerControllerDelegate, UINavigationControllerDelegate {
    
    //MARK: Properties
    @IBOutlet weak var nameTextField: UITextField!
    
    @IBOutlet weak var courseNameLabel: UILabel!
    
    @IBOutlet weak var photoImageView: UIImageView!
    
    @IBOutlet weak var saveButton: UIBarButtonItem!
    
    @IBOutlet weak var courseContentTextView: UITextView!
    
    var course: Course?
    
    // For doodle
    var path = UIBezierPath()
    
    let ref = Database.database().reference()
    
    // For picking images
    let imagePickerController = UIImagePickerController()
    
    var videoData:Data?
    
    override func viewDidLoad() {
        
        super.viewDidLoad()
    
        // Handle the text field’s user input through delegate callbacks.
        nameTextField.delegate = self
        
        // Set up views if editing an existing Course.
        if let course = course {
            navigationItem.title = course.name
            nameTextField.text   = course.name
            photoImageView.image = course.coursePhoto
            courseContentTextView.text = course.courseContent
        }
        
        // Enable the Save button only if the text field has a valid Course name.
        updateSaveButtonState()
    }
    
    //MARK: UITextFieldDelegate
    
    func textFieldDidBeginEditing(_ textField: UITextField) {
        saveButton.isEnabled = false
    }
    
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        // Hide the keyboard.
        textField.resignFirstResponder()
        return true
    }
    
    func textFieldDidEndEditing(_ textField: UITextField) {
        courseNameLabel.text = textField.text
        updateSaveButtonState()
        navigationItem.title = textField.text
    }
    
    //MARK: UIImagePickerControllerDelegate
    func imagePickerControllerDidCancel(_ picker: UIImagePickerController) {
        dismiss(animated: true, completion: nil)
    }
    
    // After selecting image
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey : Any]){

        let media = info[UIImagePickerController.InfoKey.mediaType]
        
        if media as? String == "public.movie" {
            guard let selectedVideo = info[UIImagePickerController.InfoKey.mediaURL] as? URL else {
                fatalError("Expected a video, but was provided the following: \(info)")
            }
            
            do {
                self.videoData = try Data(contentsOf: selectedVideo)
            } catch {
                print("Unable to load data: \(error)")
            }
//            photoImageView.image will be a hardcoded photo: Video was uploaded
            
        } else {
            guard let selectedImage = info[UIImagePickerController.InfoKey.originalImage] as? UIImage else {
                fatalError("Expected an image, but was provided the following: \(info)")
            }
            photoImageView.image = selectedImage
        }
        
        dismiss(animated: true, completion: nil)
    }
    
    //MARK: Navigation
    
    @IBAction func cancel(_ sender: UIBarButtonItem) {
        // Depending on style of presentation (modal or push presentation), this view controller needs to be dismissed in two different ways.
        let isPresentingInAddCourseMode = presentingViewController is UINavigationController
        
        if isPresentingInAddCourseMode {
            dismiss(animated: true, completion: nil)
        }
        else if let owningNavigationController = navigationController{
            owningNavigationController.popViewController(animated: true)
        }
        else {
            fatalError("The ViewController is not inside a navigation controller.")
        }
    }
    
    // This method lets you configure a view controller before it's presented.
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        
        super.prepare(for: segue, sender: sender)
                
        // Configure the destination view controller only when the save button is pressed.
        guard let button = sender as? UIBarButtonItem, button === saveButton else {
            print("The save button was not pressed, cancelling")
            return
        }
        
        let name = nameTextField.text ?? ""
        let photo = photoImageView.image
        let courseContent = courseContentTextView.text ?? ""
        let index = course?.index ?? ""
       
        // Set the course to be passed to CourseTableViewController after the unwind segue.
        course = Course(name: name, coursePhoto: photo, courseContent: courseContent, index: index)
    }
    
    //MARK: Actions
    
    // Photo picker
    @IBAction func selectImageFromPhotoLibrary(_ sender: UITapGestureRecognizer) {
        // Hide the keyboard.
        nameTextField.resignFirstResponder()

        // Pick from photo library
        imagePickerController.sourceType = .photoLibrary
        imagePickerController.delegate = self
        // Only allow photos and videos
        imagePickerController.mediaTypes = ["public.image", "public.movie"]

        present(imagePickerController, animated: true, completion: nil)
    }
    

    // for doodles
    @IBAction func unwindToCourseEdit(sender: UIStoryboardSegue) {
        if let sourceViewController = sender.source as? DoodleViewController /*, let course = sourceViewController.course */{
            
            print("back to edit page")
            
        }
    }
    
    //MARK: Private Methods
    
    private func updateSaveButtonState() {
        // Disable the Save button if the text field is empty.
        let text = nameTextField.text ?? ""
        saveButton.isEnabled = !text.isEmpty
    }
    
}

