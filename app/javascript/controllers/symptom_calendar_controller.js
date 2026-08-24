import { Controller } from "@hotwired/stimulus"

// Highlights calendar days that reported the selected symptom, entirely client-side.
// Each day carries its own symptom ids so highlighting stays correct after a
// Turbo Frame month navigation swaps in a new set of day elements.
export default class extends Controller {
  static targets = ["filter", "day"]

  filterChanged() {
    this.dayTargets.forEach((day) => this.applyHighlight(day))
  }

  dayTargetConnected(day) {
    this.applyHighlight(day)
  }

  applyHighlight(day) {
    const symptomId = this.filterTarget.value
    const symptomIds = JSON.parse(day.dataset.symptomIds || "[]").map(String)
    const isMatch = symptomId !== "" && symptomIds.includes(symptomId)
    day.classList.toggle("has-background-warning", isMatch)
  }
}
