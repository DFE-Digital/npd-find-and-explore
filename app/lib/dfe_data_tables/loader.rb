# frozen_string_literal: true

module DfEDataTables
  class Loader
    def initialize(data_tables_path)
      data_tables_workbook = Roo::Spreadsheet.open(data_tables_path)

      @sheets_to_process = [
        DfEDataTables::Parsers::ScPupil.new(data_tables_workbook),
        DfEDataTables::Parsers::ScAddresses.new(data_tables_workbook),
        DfEDataTables::Parsers::PruCensus.new(data_tables_workbook),
        DfEDataTables::Parsers::EarlyYearsCensus.new(data_tables_workbook),
        DfEDataTables::Parsers::AltProvision.new(data_tables_workbook),
        DfEDataTables::Parsers::ApAddresses.new(data_tables_workbook),
        DfEDataTables::Parsers::Eyfsp.new(data_tables_workbook),
        DfEDataTables::Parsers::Phonics.new(data_tables_workbook),
        DfEDataTables::Parsers::Ks1.new(data_tables_workbook),
        DfEDataTables::Parsers::Ks2.new(data_tables_workbook),
        DfEDataTables::Parsers::Year7.new(data_tables_workbook),
        DfEDataTables::Parsers::Ks3.new(data_tables_workbook),
        DfEDataTables::Parsers::Ks4.new(data_tables_workbook),
        DfEDataTables::Parsers::Ks5.new(data_tables_workbook),
        DfEDataTables::Parsers::Cin.new(data_tables_workbook),
        DfEDataTables::Parsers::Cla.new(data_tables_workbook),
        DfEDataTables::Parsers::Absence.new(data_tables_workbook),
        DfEDataTables::Parsers::ExclusionsUpTo2005.new(data_tables_workbook),
        DfEDataTables::Parsers::ExclusionsFrom2005.new(data_tables_workbook),
        DfEDataTables::Parsers::Plams.new(data_tables_workbook),
        DfEDataTables::Parsers::Nccis.new(data_tables_workbook),
        DfEDataTables::Parsers::Isp.new(data_tables_workbook),
        DfEDataTables::Parsers::Ypmad.new(data_tables_workbook)
      ]

      process
      upload
    end

    private

    def process
      # For each worksheet
      @sheets_to_process.each do |sheet_parser|
        byebug
        sheet = sheet_parser.to_h
        puts sheet[:name]

        # For each block within a sheet
        sheet[:data_blocks].each do |block|
          block_name = block[:table_name] || sheet[:name]
          headers = sheet_parser.sheet.row(block[:header_row])

          # Cast empty strings to nil
          headers.map{ |cell| (cell.instance_of?(String) && cell.empty?) ? nil : cell }

          # Remove nils from the end of the header list
          headers = headers.reverse.drop_while(&:nil?).reverse

          # The first row is either explicitly specified OR the row after the header
          first_row_number = block[:first_row] || (block[:header_row] + 1)
          last_row_number = block[:last_row]

          (first_row_number..last_row_number).each do |row_number|
            row = sheet_parser.sheet.row(row_number)

            next if row.compact.empty?

            data_element = {
              group_name: sheet[:name],
              table_name: block_name,
            }

            row.each_with_index do |cell, index|
              # Don't collect (generally empty) cells outside the table
              next if headers[index].nil?

              # Cast empty strings to nil, so we don't break the ElasticSearch ingestion
              data_element[headers[index]] = (cell.instance_of?(String) && cell.empty?) ? nil : cell
            end

            # A really specific instance of merged cells in the CLA table on row 28
            next if sheet[:name] == 'CLA_05-06_to_16-17' && data_element["NPDAlias"].nil?

            # Post-process to add structure
            # TODO: cope with SUM SC Addresses
            data_element["Collection term"] = data_element["Collection term"]&.split(', ')

            npd_alias = data_element.delete("NPDAlias") || data_element.delete('NPD Alias ') || data_element["NPD Alias"]
            npd_alias = npd_alias.split("\n")
            data_element["NPD Alias"] = npd_alias

            # Years can be written as "2006/07 only. Coerce that into "2006/07 - 2006-07" for consistency.
            years_populated = data_element.delete("Years populated") || data_element["Years Populated"]

            # KS3 Result Table contains no years collected data
            if years_populated
              years_populated = years_populated.gsub(/(.*) only/, '\1 - \1')
              data_element["Years Populated"] = years_populated

              # Break up years into array [start, end]
              years_populated = years_populated.split(/ *- */)

              # Create collected_from for collection from Years Populated
              start_year = years_populated.first[0..3].to_i
              start_date = Date.new(start_year,9,1)
              data_element[:collected_from] = years_populated.first
              data_element[:collected_from_date] = start_date

              # Create collected_until for collection from Years Populated
              if years_populated.size == 2
                end_year = years_populated.last[0..3].to_i
                end_date = Date.new(end_year + 1 ,9, 1)
                data_element[:collected_until] = years_populated.last
                data_element[:collected_until_date] = end_date
              else
                data_element[:collected_until] = 'Present'
              end

              # Finally, coerce these into a full list of years
              # data_element["Years Populated"] = years_populated
            end

            category = Category.find_or_create_by(name: 'No Category')
            concept = Concept.find_or_create_by(name: 'No Concept', category: category)

            params = {
              source_db_name: '',
              source_table_name: data_element.delete('table_name'),
              source_attribute_name: data_element.delete('FieldReference'),
              identifiability: data_element.delete('Identifiability'),
              sensitivity: data_element.delete('Sensitivity'),
              concept: concept
            }
            element = DataElement.create(params)
            element.additional_attributes = data_element
            element.save
          end

          # puts "\t#{block_name}: #{sheet_parser.sheet.row(block[:header_row])[0]}"
        end
        #

        #puts sheet.row(5).cell(1)
        #puts "---------"
      end
    end

    def upload
      byebug
    end
  end
end
