import { Controller } from "@hotwired/stimulus"
import TomSelect from "tom-select"

export default class extends Controller {
  static values = {
    options: Array
  }

  connect() {
    this.select = new TomSelect(this.element, {
      plugins: ['remove_button'],
      maxItems: 5,
      options: this.optionsValue.map(tag => ({ value: tag.id, text: tag.name })),
      create: false,
      placeholder: "Type to search tags..."
    })
  }

  disconnect() {
    if (this.select) {
      this.select.destroy()
    }
  }
}
