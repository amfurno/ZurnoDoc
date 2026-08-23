import { Controller } from "@hotwired/stimulus"

// Highlights calendar days that reported the selected symptom, entirely client-side.
export default class extends Controller {
  static targets = ["filter", "day"]
  static values = { data: Object }

  filterChanged() {
    const symptomId = this.filterTarget.value

    this.dayTargets.forEach((day) => {
      const date = day.dataset.date
      const symptomIds = (this.dataValue[date] || []).map(String)
      const isMatch = symptomId !== "" && symptomIds.includes(symptomId)
      day.classList.toggle("has-background-warning", isMatch)
    })
  }
}
