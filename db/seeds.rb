# frozen_string_literal: true

# This file should contain all the record creation needed to seed the database with its default values.
# The data can then be loaded with the rails db:seed command (or created alongside the database with db:setup).
#
# Examples:
#
#   movies = Movie.create([{ name: 'Star Wars' }, { name: 'Lord of the Rings' }])
#   Character.create(name: 'Luke', movie: movies.first)

demographics = Category.create!(name: 'Demographics',
                                description: Faker::Lorem.sentence(15))

demographics.children.create(name: 'Age',
                             description: 'Pupil ages (in years and months) at the start of the academic year',
                             parent: demographics)

Category.create!(name: 'Gender',
                 description: 'Pupil gender',
                 parent: demographics)

Category.create!(name: 'Ethnicity',
                 description: 'Ethnic Group (inc. minor and major categories)',
                 parent: demographics)

Category.create!(name: 'Family',
                 description: Faker::Lorem.sentence(15))

socio_economic_status = Category.create!(name: 'Socio economic status',
                                         description: 'Free school meals (current and previous eligibility), Income deprivation affecting children indices (inc. rank and score)')

Category.create!(name: 'Free school meals',
                 description: 'In England a free school meal is a statutory benefit available to school-aged children from families who receive other qualifying benefits and who have been through the relevant registration process.',
                 parent: socio_economic_status)

Category.create!(name: 'IDACI',
                 description: 'IDACI is an index of deprivation used in the United Kingdom. The index is calculated by the Office of the Deputy Prime Minister and measures in a local area the proportion of children under the age of 16 that live in low income households.',
                 parent: socio_economic_status)

geographic = Category.create!(name: 'Geographic')
Category.create!(name: 'Location',
                 description: 'Pupil and town postcode, pupil locality, local authority and establishment, administrative area.',
                 parent: geographic)

Category.create!(name: 'Mobility',
                 description: 'Mobility indicator, distance to nearest/current school, nearest school in the local authority area',
                 parent: geographic)

education = Category.create!(name: 'Education',
                             description: Faker::Lorem.sentence(15))
Category.create!(name: 'History',
                 description: Faker::Lorem.sentence(15),
                 parent: education)

exclusions = Category.create!(name: 'Exclusions', parent: education)

exclusion_dates = Category.create!(name: 'Exclusion dates', parent: exclusions)
Category.create!(name: 'Date of exclusion', parent: exclusion_dates)
Category.create!(name: 'Mode of travel', parent: exclusion_dates)
Category.create!(name: 'Term when started', parent: exclusion_dates)
Category.create!(name: 'Academic year reported', parent: exclusion_dates)
Category.create!(name: 'Academic year started', parent: exclusion_dates)

exclusion_details = Category.create!(name: 'Exclusion details', parent: exclusions)

Category.create!(name: 'Reason', parent: exclusion_details)
Category.create!(name: 'Category', parent: exclusion_details)
Category.create!(name: 'Permanent exclusion indicator', parent: exclusion_details)
Category.create!(name: 'Local Authority responsible', parent: exclusion_details)
Category.create!(name: 'Number of enrollements', parent: exclusion_details)
Category.create!(name: 'Number of sessions excluded', parent: exclusion_details)
Category.create!(name: 'Multiple exclusions', parent: exclusion_details)
Category.create!(name: 'Fixed exclusions', parent: exclusion_details)
Category.create!(name: 'Permanent exclusion count', parent: exclusion_details)
Category.create!(name: 'Fixed sessions', parent: exclusion_details)

absence = Category.create!(name: 'Absence')
Category.create!(name: 'Authorised', parent: absence)
Category.create!(name: 'Unauthorised', parent: absence)
Category.create!(name: 'Persistent', parent: absence)
Category.create!(name: 'Administrative area', parent: absence)
Category.create!(name: 'Overall absence', parent: absence)

attainment = Category.create!(name: 'Attainment')
Category.create!(name: 'A level', parent: attainment)

gcse = Category.create!(name: 'GCSE', parent: attainment)
gcse.children.create(name: 'Maths highest prior attainment', description: Faker::Lorem.sentence(15))
gcse.children.create(name: 'Maths prior attainment', description: Faker::Lorem.sentence(15))
gcse.children.create(name: 'English highest prior attainment', description: Faker::Lorem.sentence(15))
gcse.children.create(name: 'English prior attainment', description: Faker::Lorem.sentence(15))
gcse.children.create(name: 'Maths funding exemption', description: Faker::Lorem.sentence(15))
gcse.children.create(name: 'English funding exemption', description: Faker::Lorem.sentence(15))

# nvq = attainment.create('NVQ', description: Faker::Lorem.sentence(15))
# "","","",In published figures
# "","","",Early years foundation
# "","","","",Good level of development indicator
# "","","","","Personal, Social and Emotional Development"
# "","","","","",Self-confidence and self-awareness
# "","","","","",Managing feelings and behaviour
# "","","","","",Making relationships
# "","","","","Communication, Language and Literacy"
# "","","","","",Listening and attention
# "","","","","",Speaking
# "","","","","",Reading
# "","","","","",Literacy
# "","","","","",Writing
# "","","","","Problem Solving, Reasoning and Numeracy"
# "","","","","",Numbers
# "","","","","","Shape, space and measures"
# "","","","",Knowledge and Understanding of the World
# "","","","","",People and communities
# "","","","","",The World
# "","","","","",Technology
# "","","","",Physical Development
# "","","","","",Moving and handling
# "","","","","",Health and self-care
# "","","","",Creative Development
# "","","","","",Exploring and using media and materials
# "","","","","",Being imaginative
# "","","",Phonics
# "","","","",Phonics mark
# "","","","",Phonics outcome
# "","","",Key stage 1
# "","","","",English
# "","","","",Maths
# "","","","",GNVQ
# "","","","","",Sessions possible
# "","","","","","",Term when reported
# "","","","",Science
# "","","",Key stage 2
# "","","","",Examination details
# "","","","","",Eligibility
# "","","","","",Absences
# "","","","",Outcomes
# "","","","","",English
# "","","","","",Maths
# "","","","","",Science
# "","","","","",Reached standard grade
# "","","","","",High results
# "","","","","",Progress scores
# "","","","","",Average point score
# "","","","","",Value added score
# "","","","","",P-Scales
# "","","","",Teacher assessment
# "","","","",Prior attainment
# "","","","",Single level tests
# "","","","",Predicted grades
# "","","","",Mobility
# "","","",Key stage 3
# "","","","",Examination detail
# "","","","","",Eligibility
# "","","","","",Absences
# "","","","",Teacher assessment
# "","","","",Mobility
# "","","","",Averages
# "","","","",Outcomes
# "","","","","",English
# "","","","","",Maths
# "","","","","",Science
# "","","",Key Stage 4
# "","","","",Early taker
# "","","","",Exam entry details
# "","","","","",Total number of Full GCSE entries.
# "","","","","",Total number of Short GCSE entries.
# "","","","","",Total number of Double Award Vocational GCSE entries.
# "","","","","",Total number of Full Intermediate GNVQ entries.
# "","","","","",Total number of Full Foundation GNVQ entries.
# "","","","","",Total number of Part One Intermediate GNVQ entries.
# "","","","","",Total number of Part One Foundation GNVQ entries.
# "","","","","",Total number of Language Intermediate GNVQ entries.
# "","","","","",Total number of Language Foundation GNVQ entries.
# "","","","","",Total number of Entry Level Qualification entries.
# "","","","","",Total number of Key Skills at Level 1entries.
# "","","","","",Total number of Key Skills at Level 2 entries.
# "","","","","","Entered all of Biology, Physics, Chemistry  GCSEs or ASs"
# "","","","","",Entered for at least 1 Full GCSE Modern Foreign Language qualification.
# "","","","","",Entered for at least 1 Modern Foreign Language qualification.
# "","","","","",Total number of GCSE/GNVQ entries (GCSE equivalencies) from 2001/02 to 2009/10.
# "","","","","",Total number of GCSE and equivalents entries (GCSE equivalencies).
# "","","","","",Uncapped points per qualification entry (including equivalents)
# "","","","","",Uncapped points per GCSE entry (excluding equivalents)
# "","","","","",Pupil entered for at least 1 GCSE or equivalent
# "","","","","",Pupil entered for 5 or more GCSE or equivalent
# "","","","",Outcomes
# "","","","","",Full GCSE
# "","","","","","",Grades
# "","","","","","","",Grade A*
# "","","","","","","",Grade A
# "","","","","","","",Grade B
# "","","","","","","",Grade C
# "","","","","","","",Grade D
# "","","","","","","",Grade E
# "","","","","","","",Grade F
# "","","","","","","",Grade G
# "","","","","","","",Grade U
# "","","","","","",Grade scale
# "","","","","","","",Grade D to G
# "","","","","","","",Grade A* to A
# "","","","","","","",Grade A* to C
# "","","","","","","",Grade A* to G
# "","","","","",Short GCSE
# "","","","","","",Grade A*
# "","","","","","",Grade A
# "","","","","","",Grade B
# "","","","","","",Grade C
# "","","","","","",Grade D
# "","","","","","",Grade E
# "","","","","","",Grade F
# "","","","","","",Grade G
# "","","","","","",Grade A* to A
# "","","","","","",Grade A* to C
# "","","","","","",Grade A* to G
# "","","","","","",Grade D to G
# "","","","","",GCSE Double awards
# "","","","","","",Grade A*A*
# "","","","","","",Grade AA
# "","","","","","",Grade BB
# "","","","","","",Grade CC
# "","","","","","",Grade DD
# "","","","","","",Grade EE
# "","","","","","",Grade FF
# "","","","","","",Grade GG
# "","","","","","",Grade A*A* to AA
# "","","","","","",Grade AA to CC
# "","","","","","",Grade AA to GG
# "","","","","","",Grade DD to GG
# "","","","","",GNVQs
# "","","","","","",Number of Distinction Intermediates
# "","","","","","",Number of Merit Intermediates
# "","","","","","",Number of Pass Intermediates
# "","","","","","",Number of Distinction Foundations
# "","","","","","",Number of Merit Foundations
# "","","","","","",Number of Pass Foundations
# "",Special educational needs
# Category.create!(name: 'Type')
# Category.create!(name: 'Provision')
# Category.create!(name: 'Funding')
