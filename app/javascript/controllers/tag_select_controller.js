import { Controller } from "@hotwired/stimulus"
import TomSelect from "tom-select"

export default class extends Controller {
  connect() {
    this.select = new TomSelect(this.element, {
      plugins: ["remove_button"],
      maxItems: 5,
      create: false,
      placeholder: "Type to search tags...",
      onItemAdd: () => {
        this.select.setTextboxValue("")
        this.select.refreshOptions()
      },
      closeAfterSelect: false
    })
  }

  disconnect() {
    if (this.select) {
      this.select.destroy()
    }
  }
}
