namespace :patient_data do
  desc "Generate faker-backed doctor and medication records for a patient"
  task :generate, [ :patient_id, :doctor_count, :medication_count ] => :environment do |_task, args|
    patient_id = args[:patient_id]
    doctor_count = args[:doctor_count].to_i.positive? ? args[:doctor_count].to_i : 3
    medication_count = args[:medication_count].to_i.positive? ? args[:medication_count].to_i : 8

    # Validate patient existence
    patient = Patient.find_by(id: patient_id)
    unless patient
      warn "Error: Patient with ID #{patient_id} not found."
      exit 1
    end

    begin
      Patient.transaction do
        # Generate doctors
        created_doctors = []
        doctor_count.times do |_|
          doctor = patient.doctors.create!(
            name: Faker::Name.name,
            practice: Faker::Company.name,
            speciality: Faker::Job.title,
            address: Faker::Address.full_address,
            phone_number: Faker::PhoneNumber.phone_number,
            fax_number: Faker::PhoneNumber.phone_number,
            email: Faker::Internet.email
          )
          created_doctors << doctor
        end

        # Generate medications
        created_medications = []
        medication_count.times do |_|
          # Randomly associate medication to a doctor (if doctors exist), or nil
          doctor = created_doctors.sample
          medication = patient.medications.create!(
            name: Faker::Lorem.words(number: Faker::Number.between(from: 1, to: 3)).join(" ").titleize,
            drug_class: Faker::Job.title,
            dosage: "#{Faker::Number.between(from: 1, to: 1000)} #{[ 'mg', 'ml', 'units' ].sample}",
            date_started: Faker::Date.backward(days: 365),
            date_stopped: [ nil, Faker::Date.backward(days: 1) ].sample,
            notes: Faker::Lorem.paragraph(sentence_count: 2),
            side_effects: Faker::Lorem.sentence,
            doctor_id: doctor&.id
          )
          created_medications << medication
        end

        puts "✓ Generated #{created_doctors.count} doctor(s) and #{created_medications.count} medication(s) for patient #{patient.name} (ID: #{patient_id})"
      end
    rescue StandardError => e
      warn "Error generating data: #{e.message}"
      exit 1
    end
  end
end
