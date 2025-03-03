import { Controller } from "@hotwired/stimulus"

export default class extends Controller {
  static targets = ["form", "fileInput"]

  connect() {
    this.fileInputTarget.style.display = 'none'
  }

  triggerFileInput(event) {
    event.preventDefault()
    console.log("triggerFileInput called")
    this.fileInputTarget.click()
  }

  submitForm(event) {
    console.log("submitForm called")
    const files = this.fileInputTarget.files
    if (files && files.length > 0) {
      console.log("Files selected:", files[0].name)
      this.formTarget.submit()
    } else {
      console.log("No files selected")
    }
  }
}