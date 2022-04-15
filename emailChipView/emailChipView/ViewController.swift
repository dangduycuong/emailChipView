//
//  ViewController.swift
//  emailChipView
//
//  Created by cuongdd on 15/04/2022.
//

import UIKit

class LabelInset: UILabel {
    var contentInset: UIEdgeInsets = .zero {
        didSet {
            setNeedsDisplay()
        }
    }
    override func drawText(in rect: CGRect) {
        super.drawText(in: rect.inset(by: contentInset))
    }
    
    override public var intrinsicContentSize: CGSize {
        let size = super.intrinsicContentSize
        return CGSize(width: size.width + contentInset.left + contentInset.right, height: size.height + contentInset.top + contentInset.bottom)
    }
}

class SendViewController: UIViewController {
    @IBOutlet weak var tableView: UITableView!
    @IBOutlet weak var heightTableView: NSLayoutConstraint!
    @IBOutlet weak var topButtonMyContactsConstraint: NSLayoutConstraint!
    @IBOutlet weak var emailTextField: UITextField!
    @IBOutlet weak var contentView: UIView!
    @IBOutlet weak var bottomView: UIView!
    @IBOutlet weak var cancelButton: UIButton!
    @IBOutlet weak var sendEmailButton: UIButton!
    
    fileprivate lazy var titleLabel: UILabel = {
        let label = LabelInset()
        label.font = UIFont.systemFont(ofSize: 16)
        label.textColor = #colorLiteral(red: 0.3137254902, green: 0.337254902, blue: 0.368627451, alpha: 1)
        label.textAlignment = .center
        label.contentInset = UIEdgeInsets(top: -12, left: 0, bottom: 0, right: 0)
        label.text = "Send Document"
        label.heightAnchor.constraint(equalToConstant: 24).isActive = true
        return label
    }()
    
    var tagsArray = [String]()
    var isEditEmail: Bool = false
    var indexTagEdit: Int = 0
    var recentlyEmails = [String]()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        for i in 0..<5 {
            recentlyEmails.append("email\(i)@gmail.com")
        }
        setupUI()
        
        bottomView.isHidden = true
        tableView.reloadData()
        
        topButtonMyContactsConstraint.constant = 128
        navigationItem.titleView = titleLabel
        
        navigationItem.setHidesBackButton(true, animated: true)
    }
    
    private func setupUI() {
        sendEmailButton.isUserInteractionEnabled = false
        tableView.separatorStyle = .none
        heightTableView.constant = CGFloat(64 * recentlyEmails.count)
    }
    
    func removeChipViewInContentView() {
        for tempView in contentView.subviews {
            if tempView.tag >= 100 {
                tempView.removeFromSuperview()
            }
        }
    }
    func createTagCloud(withArray data: [AnyObject]) {
        sendEmailButton.backgroundColor = #colorLiteral(red: 0.8901960784, green: 0.9058823529, blue: 0.9294117647, alpha: 1)
        sendEmailButton.isUserInteractionEnabled = false
        removeChipViewInContentView()
        var xPos: CGFloat = 16.0
        var ypos: CGFloat = 128.0
        var tag: Int = 100 //start at 100
        for str in data  {
            let startstring = str as! String
            let widthOfText = startstring.widthOfString(usingFont: UIFont.boldSystemFont(ofSize: 14)) //chieu rong cua chu
            let checkWholeWidth = CGFloat(xPos) + CGFloat(widthOfText) + CGFloat(40.0)//40.0 is cross button width and gap to righht (0)
            if checkWholeWidth > UIScreen.main.bounds.size.width - 32.0 {
                //we are exceeding size need to change xpos
                xPos = 16.0
                ypos = ypos + 32.0 + 8.0
            }
            
            let emailView = createChipView(x: xPos, y: ypos, width: 16 + widthOfText + 40, tag: tag, email: startstring)
            
            let label = createEmailLabel(width: widthOfText, height: emailView.frame.size.height, text: startstring, tag: tag)
            emailView.addSubview(label)
            
            let itemButton = createEmailItemButton(width: emailView.frame.size.width, height: emailView.frame.size.height, tag: tag)
            emailView.addSubview(itemButton)
            
            
            let removeButton = createRemoveButton(x: emailView.frame.size.width - 40.0, tag: tag, email: startstring)
            emailView.addSubview(removeButton)
            
            xPos = xPos + emailView.frame.size.width + 8
            contentView.addSubview(emailView)
            DispatchQueue.main.async {
                self.topButtonMyContactsConstraint.constant = ypos + 32 + 36
                self.contentView.layoutIfNeeded()
            }
            tag += 1
        }
    }
    
    func createChipView(x: CGFloat, y: CGFloat, width: CGFloat, tag: Int, email: String) -> UIView {
        let emailView = UIView(frame: CGRect(x: x, y: y, width: width, height: 32.0))
        emailView.layer.cornerRadius = 8
        
        emailView.backgroundColor = UIColor(red: 33.0/255.0, green: 135.0/255.0, blue:199.0/255.0, alpha: 1.0)
        emailView.backgroundColor = .white
        emailView.layer.borderWidth = 1
        emailView.layer.borderColor = UIColor(red: 0.891, green: 0.908, blue: 0.929, alpha: 1).cgColor
        emailView.tag = tag
        if isEditEmail, tag == indexTagEdit {
            emailView.backgroundColor = #colorLiteral(red: 0.8901960784, green: 0.9058823529, blue: 0.9294117647, alpha: 1)
        }
        
        if isValidEmail(email) {
            sendEmailButton.isUserInteractionEnabled = true
            sendEmailButton.backgroundColor = #colorLiteral(red: 0.007843137255, green: 0.2470588235, blue: 0.3843137255, alpha: 1)
        } else {
            emailView.backgroundColor = .red
        }
        
        return emailView
    }
    
    func createEmailLabel(width: CGFloat, height: CGFloat, text: String, tag: Int) -> UILabel {
        let label = UILabel(frame: CGRect(x: 16.0, y: 0.0, width: width, height: height))
        
        label.font = UIFont.boldSystemFont(ofSize: 14)
        label.text = text
        label.textColor = UIColor(red: 0.314, green: 0.337, blue: 0.369, alpha: 1)
        
        if isValidEmail(text) == false {
            label.textColor = .white
        }
        
        return label
    }
    
    func createEmailItemButton(width: CGFloat, height: CGFloat, tag: Int) -> UIButton {
        let itemButton = UIButton()
        
        itemButton.frame = CGRect(x: 0, y: 0, width: width, height: height)
        itemButton.tag = tag
        itemButton.addTarget(self, action: #selector(clickEmailItem(_:)), for: .touchUpInside)
        
        return itemButton
    }
    
    func createRemoveButton(x: CGFloat, tag: Int, email: String) -> UIButton {
        let removeButton = UIButton(type: .custom)
        removeButton.frame = CGRect(x: x, y: 0.0, width: 40.0, height: 32.0)
        let removeIcon = UIImage(named: "icons8-close")?.withRenderingMode(.alwaysTemplate)
        let imageView = UIImageView(image: removeIcon)
        imageView.tintColor = #colorLiteral(red: 0.3137254902, green: 0.337254902, blue: 0.368627451, alpha: 1)
        
        removeButton.setImage(imageView.image, for: .normal)
        removeButton.imageEdgeInsets = UIEdgeInsets(top: 10, left: 10, bottom: 10, right: 18)
        removeButton.tag = tag
        removeButton.addTarget(self, action: #selector(removeTag(_:)), for: .touchUpInside)
        removeButton.tintColor = #colorLiteral(red: 0.3137254902, green: 0.337254902, blue: 0.368627451, alpha: 1)
        
        if isValidEmail(email) == false {
            removeButton.tintColor = .white
        }
        
        return removeButton
    }
    
    func isValidEmail(_ email: String) -> Bool {
        let emailRegEx = "[A-Z0-9a-z._%+-]+@[A-Za-z0-9.-]+\\.[A-Za-z]{2,64}"
        let emailPred = NSPredicate(format:"SELF MATCHES %@", emailRegEx)
        return emailPred.evaluate(with: email)
    }
    
    private func removeAnEmail(tag: Int) {
        tagsArray.remove(at: tag - 100)
        createTagCloud(withArray: tagsArray as [AnyObject])
        if tagsArray.isEmpty {
            topButtonMyContactsConstraint.constant = 128
        }
    }
    
    @objc func removeTag(_ sender: AnyObject) {
        removeAnEmail(tag: sender.tag)
    }
    
    private func addAnEmailToList(email: String) {
        tagsArray.append(email)
        createTagCloud(withArray: tagsArray as [AnyObject])
    }
    
    @objc func clickEmailItem(_ sender: AnyObject) {
        isEditEmail = true
        let email = tagsArray[sender.tag - 100]
        indexTagEdit = sender.tag
        emailTextField.text = email
        emailTextField.becomeFirstResponder()
        
        emailTextField.selectAll(self)
        createTagCloud(withArray: tagsArray as [AnyObject])
    }
    
    @IBAction func tapAddEmail(_ sender: Any) {
        if let text = emailTextField.text {
            addAnEmailToList(email: text)
        }
        emailTextField.text = ""
    }
    
    @IBAction func tapCancel(_ sender: Any) {
        navigationController?.popViewController(animated: true)
    }
    
    @IBAction func tapSendEmail(_ sender: Any) {
        
    }
    
}

extension SendViewController: UITableViewDelegate, UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return recentlyEmails.isEmpty ? 1 : recentlyEmails.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "Cell", for: indexPath)
        
        let paragraphStyle = NSMutableParagraphStyle()
        let button = UIButton(frame: CGRect(x: cell.contentView.bounds.size.width - 40, y: 0, width: 47, height: 64))
        paragraphStyle.lineHeightMultiple = 1.25
        cell.textLabel?.font = UIFont.boldSystemFont(ofSize: 16)
        if recentlyEmails.isEmpty {
            cell.textLabel?.textColor = .darkGray
            cell.textLabel?.attributedText = NSMutableAttributedString(string: "No email", attributes: [NSAttributedString.Key.paragraphStyle: paragraphStyle])
            cell.textLabel?.textAlignment = .center
            
            button.isHidden = true
            button.removeFromSuperview()
        } else {
            cell.textLabel?.textColor = .darkText
            let image = UIImage(named: "icons8-delete")?.withRenderingMode(.alwaysTemplate)
            let imageView = UIImageView(image: image)
            imageView.tintColor = .black
            button.setImage(imageView.image, for: .normal)
            button.imageEdgeInsets = UIEdgeInsets(top: 21, left: 8, bottom: 21, right: 17)
            button.tintColor = .black
            cell.addSubview(button)
            button.tag = indexPath.row
            button.addTarget(self, action: #selector(removeRecentlyEmails(_:)), for: .touchUpInside)
            
            let email = recentlyEmails[indexPath.row]
            cell.textLabel?.attributedText = NSMutableAttributedString(string: email, attributes: [NSAttributedString.Key.paragraphStyle: paragraphStyle])
            let backgroundView = UIView()
            backgroundView.backgroundColor = .cyan
            cell.selectedBackgroundView = backgroundView
        }
        
        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        emailTextField.resignFirstResponder()
        if recentlyEmails.isEmpty == false {
            let email = recentlyEmails[indexPath.row]
            if tagsArray.contains(email) == false {
                addAnEmailToList(email: email)
            }
        }
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 64
    }
    
    @objc func removeRecentlyEmails(_ sender: AnyObject) {
        print("cdd removeRecentlyEmails")
        if recentlyEmails.isEmpty == false {
            recentlyEmails.remove(at: sender.tag)
        }
        heightTableView.constant = recentlyEmails.isEmpty ? 64.0 : CGFloat(recentlyEmails.count * 64)
        tableView.reloadData()
    }
    
    
}

extension SendViewController: UITextFieldDelegate {
    func textFieldDidBeginEditing(_ textField: UITextField) {
        bottomView.isHidden = false
    }
    
    func textField(_ textField: UITextField, shouldChangeCharactersIn range: NSRange, replacementString string: String) -> Bool {
        if let char = string.cString(using: String.Encoding.utf8) {
            let isBackSpace = strcmp(char, "\\b")
            if (isBackSpace == -92) {
                print("Backspace was pressed")
                if isEditEmail {
                    isEditEmail = false
                    removeAnEmail(tag: indexTagEdit)
                }
            }
        }
        
        return true
    }
    
    func textFieldDidChangeSelection(_ textField: UITextField) {
        if isEditEmail {
            if let email = textField.text {
                tagsArray[indexTagEdit - 100] = email
            }
        }
    }
    
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        if isEditEmail {
            isEditEmail = false
            createTagCloud(withArray: tagsArray as [AnyObject])
            textField.text = ""
        }
        textField.resignFirstResponder()
        return true
    }
    
    func textFieldDidEndEditing(_ textField: UITextField) {
        bottomView.isHidden = true
    }
}

extension String {
    func widthOfString(usingFont font: UIFont) -> CGFloat {
        let fontAttributes = [NSAttributedString.Key.font: font]
        let size = self.size(withAttributes: fontAttributes)
        return size.width
    }
}

