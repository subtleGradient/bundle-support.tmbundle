#!/usr/bin/env ruby -w

require "yaml"
require "find"

$: << File.join(File.split(__FILE__).first, '../lib')
require "osx/plist"

$legal_scopes, allowed_globals =
  YAML.load(DATA).values_at(*%w[legal_scopes allowed_globals])

def visit_value(value, bundle_name = nil)
  case value
  when Array
    value.each { |v| visit_value v, bundle_name }
  when Hash
    value.each_pair do |name, v|
      if name == "name" || name == "contentName"
        unless $legal_scopes.any? { |scope| scope.size <= v.size && scope == v[0...(scope.size)] }
          print "#{bundle_name}: " unless bundle_name.nil?
          puts v
        end
      else
        visit_value v, bundle_name
      end
    end
  end
end

# parse options
require "optparse"

options = {:legal_scopes => true, :global_scopes => true, :white_list => true}

ARGV.options do |opts|
  opts.banner = "Usage:  #{File.basename($PROGRAM_NAME)} [OPTIONS] BUNDLES"
  
  opts.separator ""
  opts.separator "Specific Options:"
  
  opts.on( "-l", "--skip-legal-scopes", String,
           "Don't perform the check for legal scopes." ) do |opt|
    options[:legal_scopes] = false
  end
  opts.on( "-g", "--skip-global-scopes", String,
           "Don't perform the check for global scopes." ) do |opt|
    options[:global_scopes] = false
  end
  opts.on( "-w", "--no-white-list", String,
           "Don't use the global scope white-list." ) do |opt|
    options[:white_list] = false
  end
  
  opts.separator "Common Options:"
  
  opts.on( "-h", "--help",
           "Show this message." ) do
    puts opts
    exit
  end
  
  begin
    opts.parse!
  rescue
    puts opts
    exit
  end
end

ARGV.each do |bundle|

  old_dir = Dir.getwd
  Dir.chdir(bundle)

  # check for valid scope names in language grammars
  if options[:legal_scopes]
    Dir["Syntaxes/*.{tmLanguage,plist}"].each do |grammar|
      open(grammar) do |io|
        plist = PropertyList.load(io)
        bundle_name = ARGV.size == 1 ? nil : File.split(bundle).last
        visit_value plist['patterns'], bundle_name   if plist['patterns']
        visit_value plist['repository'], bundle_name if plist['repository']
      end
    end
  end
  
  # check the scope assignment to automations and preferences
  if options[:global_scopes]
    %w[Snippets Macros Commands Preferences].each do |dir|
      Find.find(dir) do |path|
        if File.file?(path) and
           File.extname(path) =~ /.*\.(tm[A-Z][a-zA-Z]+|plist)\Z/
          plist = File.open(path) { |io| PropertyList.load(io) }
          uuid  = plist["uuid"]
          next if options[:white_list] and allowed_globals.include? uuid
          if plist["scope"].to_s.empty?
            puts "#{File.basename(bundle)}: #{plist["name"]} (#{uuid}) " +
                 "has a global scope."
          end
        end
      end
    end
  end

  Dir.chdir(old_dir)

end

__END__
--- 
legal_scopes: 
- comment.block.
- comment.line.
- constant.character.
- constant.language.
- constant.numeric.
- constant.other.
- entity.name.type.
- entity.name.function.
- entity.name.section.
- entity.name.tag.
- entity.other.attribute-name.
- entity.other.inherited-class.
- invalid.deprecated.
- invalid.illegal.
- keyword.control.
- keyword.operator.
- keyword.other.
- markup.bold.
- markup.changed.
- markup.deleted.
- markup.heading.
- markup.inserted.
- markup.italic.
- markup.list.
- markup.other.
- markup.quote.
- markup.raw.
- markup.underline.
- meta.
- punctuation.definition.
- punctuation.section.
- punctuation.separator.
- punctuation.terminator.
- source.
- storage.modifier.
- storage.type.
- string.interpolated.
- string.other.
- string.quoted.double.
- string.quoted.other.
- string.quoted.single.
- string.quoted.triple.
- string.regexp.
- string.unquoted.
- support.class.
- support.constant.
- support.function.
- support.other.
- support.type.
- support.variable.
- text.
- variable.language.
- variable.other.
- variable.parameter.
allowed_globals:
- 8DCBE1EB-A3CC-4559-872E-34A3643F0BC4
- FA5DC73E-AAE0-4C69-86E1-87B9E0390FD0
- 1F22884A-6702-4FB6-B4E7-D49B2431BD4E
- 20865252-80D2-4CA4-9834-391D09210C4F
- 1FE7E10E-70B4-44D7-924D-879C54F19289
- 473C6519-F164-4496-A699-F9DE2CAB56DD
- 9EA691A5-A166-4D8F-955F-270490F02827
- 00C541DE-9A5C-4C59-A075-E754BAEB25C2
- 6416A49F-8B3E-47EE-81B4-F2F7F19C6B41
- E29C9E3B-B7FB-4ED1-94C3-2F702CD090B5
- 22FC4CAB-4664-4CFC-BC8E-C2294616E464
- BE6728A5-AFC4-4D98-9EC7-C2E951483B71
- 2C5DB599-04DC-40CC-BBE8-0A73620BC42A
- 338A3670-DA8E-4036-87E0-DF2E212254C8
- 76E34DE2-1DCB-47B8-BA2F-4F3341A3AB9C
- ADCD4FCD-D39D-41B3-88D0-84C5BE115535
- F68A0A7A-75AF-4471-A9F8-3A618DD81306
- CFAAD3D2-CD4F-4F16-AB41-770AF6E460EF
- 5E76D8C8-DE61-11D9-823F-000A95A51A76
- 1C9B5F32-759D-4B3E-BA91-A83897C48026
- B2B2A814-DE60-11D9-823F-000A95A51A76
- 242ECD6E-DE5D-11D9-823F-000A95A51A76
- 627E8652-2B23-4E68-ADF9-103BA2B16074
- 5CEA8FE0-E28A-11D9-9477-000A95A51A76
- 81229AD0-DE5C-11D9-823F-000A95A51A76
- 239E196A-7106-4DC9-8FAE-0A9CA7540AFA
- 0979659D-126E-467F-AC07-599979A42D67
- 6A811265-81DC-11D9-9AA2-000D9332809C
- D04AFBD3-8110-11D9-8E5B-0011242E4184
- 674E54F5-065E-4224-9626-673903B7C0E0
- 54D1CEF2-10AB-407B-AAB2-6AEA06B297B1
- 46842464-574C-477F-9DFB-BB38EA3C85BE
- 4050A252-C604-4D0C-8545-E50B22E2715B
- 068FA312-303F-42E0-9BC7-EA6CA4324A7C
- 011517D7-AA14-46B6-9141-51411F33E6E8
- C5EF3C38-DED6-4308-90C1-BE75B4430332
- A4E0B6D9-F4A7-4A79-902E-C049102BF39A
- 37FBE527-CE10-42F5-8974-12463404AD23
- BB66B370-D68B-4AFA-A228-C28F34E2AED2
- A1D725D0-E28F-491C-8776-C6FAF0A89DF7
- AE00FFF1-C436-4826-808A-3AF6C2ABD18B
- 7CC7E11B-02BE-4F8D-9E8F-396D2CB74A98
- 381FFB1B-0CAE-40AC-A228-B575C6E1C1C4
- BD115447-20FA-43E3-8694-E8B4280C296B
- A7B73FB6-4C26-4607-8899-9595D7BF3EB1
- 56B05535-1ACD-4E55-B9FC-3BC1FAA3DBE1
- D15DAF9D-80EF-4636-885A-74F64808060A
- 44AE6B57-2AD5-4D06-972B-EEFA6FC3F266
- 99D9DBC0-E03E-46B9-9E73-13F58DCDB55B
- 8FC2E9FA-A9CE-42CD-9910-4FC9A9248BF9
- 0F1EF848-5333-4610-96FE-97C180B2653C
- 9F8B60D0-0535-4B92-8A02-A5AF47BE5306
- 9029E141-4526-4ED8-95B2-2A4E19BAD402
- F0B1A94F-3FC5-47B8-8771-FFF4EF230156
- 3FA49AEC-79AA-4E3A-BFDA-FD7E4EF8D0FE
- BA930D7C-7B5E-4BFE-9293-6B8FAF962990
- 40ABCA1E-A154-47C7-8EBC-D22DC078D295
- 667B3ED4-CA2B-402D-9445-904798AE1AA0
- 8C7398D7-1BC2-4F4D-9BA9-AE1520D764AD
- E11461A2-B186-4278-9CB9-95AAC8D9D7C0
- FBA5B6EB-2516-4940-9C8B-70645917F8BB
- 19B3B518-4B71-4AD6-BC0B-7B5477ABD2D9
- A952F27C-2200-4C2C-ABC9-69BD36FF76DF
- 2ED44A32-C353-447F-BAE4-E3522DB6944D
- 0658019F-3635-462E-AAC2-74E4FE508A9B
- 18C33747-DEB1-4F36-B1E3-EF1D544C1D96
- 2AD289D4-FBE2-40D2-B12D-3D498486B881
- 8BEF616A-19A7-4AE2-AC59-B812BF701269
- 5CFF88D2-658D-4E81-9FCA-45673D3E74DD
- 768F3AD8-30D7-4AFD-8041-5F02E5EADD44
- 52991D39-38F1-4A33-9C7D-5D39EB289889
- CA3F1BC7-8F8A-464F-BC3A-322B437F9E8E
- B0869DF4-B5E2-48A5-8550-5BABE67F6D25
- B0F37DAC-6E52-11D9-AA12-000D93589AF6
- 44B4C1CE-DD85-485A-B860-E4DFCDD0A4FE
- 9FEC1836-6E52-11D9-AA12-000D93589AF6
- 3E70551A-26B8-44FD-9D3F-25954E4ECDE4
- 19A73EFD-E8D2-44D1-A3ED-EF604BB290EF
- 71AB34F4-755D-4F16-A45F-93CD88246ED7
- F1541E0F-77EB-11D9-B807-000D93589AF6
- BA9536B4-5A7E-46D2-A268-E0ADAB9782BC
- C688B837-D48A-4088-9374-F93E7B4CCD3C
- A8369DD4-4424-4A64-B0B1-FB8BD7D8E02C
- 93A395CC-77E8-11D9-B5A8-000D93589AF6
- D1DFE75D-EAAD-4662-8F1F-F5556402054B
- 93992270-EA57-4AE0-BF91-16C9110A41E1
- 6E8B4CDA-07CD-4BFA-ABFE-5ABA14F35B8A
- D6EEB6EA-77E9-11D9-B36F-000D93589AF6
- 83F27190-D52F-414C-8AC8-7ED3ADAF2FC6
- B797AE83-EABD-4BB7-AD20-0FB24F824343
- ED977BA9-3604-4EC9-999B-39C588CD4801
- 11743544-9E2A-49BF-BA5D-655EAD6445AA
- 819B19AC-758D-42CB-903F-73A5EDD716BD
- 59DD3EDA-43DB-4819-8C50-CCBBEED5B0F7
- 0210BC81-D701-4836-A188-42D9A79F292B
- 75575B16-87B9-40A3-9101-B027DD43D31F
- 46E15B5C-A621-48E5-AD2B-A893532695A6
- 25A113EB-AA3B-40F0-B30E-ED2C2F9866C0
- DF26FEB2-2E2C-4764-B766-869113AF6E00
- CFC80127-ED10-465E-9CCE-D9282FD7893D
- 60838383-D23C-465B-9414-A1EC148F6D1D
- C8F5F526-4ED5-4E75-A0D1-D9B5143B20EE
- 296CC34F-72CA-4720-A77D-0452EEB3813C
- D8C78EA6-68A7-4625-826A-C64E51EF0724
- 7D88D67B-C562-41DB-B25B-0AA8EAF3DC36
- F56EB32C-F574-4865-83BF-976D8A826FC1
- A60EB1AE-66C8-4791-940B-6601635A7899
- A6254651-3866-4F78-8774-10FA1C1D7A6B
- 2593B8FB-279E-4BD1-8935-0D9B1699526F
- 865D7DE7-A07B-47C1-AEDC-4A88317A0EB1
- A6F3AB3E-FB21-4E93-B672-E41100E88E41
- 05A4D219-B3B9-4B74-B513-1F1CAC8B4AE0
- 49408034-6D83-41D7-B4CF-B7B9801B5982
- F60652D5-8316-11D9-8D63-000D9332809C
- E45D5856-8305-11D9-8AD4-000D9332809C
- 3AE7D1AD-8300-11D9-B216-000D9332809C
- DC7A2CCA-8301-11D9-9E93-000D9332809C
- DBF2B50A-8303-11D9-8C1E-000D9332809C
- 4B6A441D-8307-11D9-A10F-000D9332809C
- 4BBD1C32-8316-11D9-968E-000D9332809C
- BE2B6161-2E23-4C08-B438-409BB1E82DA8
- E73FA01C-7625-11D9-B58C-000A95A89C98
- 9982EC7A-7577-11D9-A32D-000A95A89C98
- A1DCDF0B-628B-4590-87C0-A551DC1F5F3A
- 092CED4D-9C4C-4ED7-BB6A-5C80D929D9FD
- 1194ED50-336C-45F8-9E73-C777FB3FAF88
- 3E208CDF-268C-4A23-902B-5628596E4BC8
- 97E895A4-B5B9-11D9-80D4-000A95A89C98
- 38C6DE3A-7664-11D9-B58C-000A95A89C98
- 556314B2-B3BF-11D9-9B1F-000A95A89C98
- D6F5F368-C476-4882-82EA-D11E22A445BF
- AD9B4CB8-7577-11D9-A32D-000A95A89C98
- 7EB957A4-A531-11D9-917B-000D9332809C
- 8FDBC987-A543-11D9-B374-000D9332809C
- C958CCC3-109D-40E0-ADB5-DFAA1A9DE8AF
- EE5F1FB2-6C02-11D9-92BA-0011242E4184
- C3045596-791D-11D9-9130-000A95766570
- D79E0650-C374-11D9-8A81-000A95BCAFA8
- C17472A0-C36B-11D9-954B-000A95BCAFA8
- 8FCB4C8F-23CD-4D2E-A9F2-C4564DFFEB2A
- 9BF6E13C-C31A-11D9-820C-000A95BCAFA8
- 70BCF12B-C35D-11D9-AB2C-000A95BCAFA8
- 5263FCE3-C32A-11D9-BFEF-000A95BCAFA8
- 0987069A-C370-11D9-AAA6-000A95BCAFA8
- C03C7374-C371-11D9-AAA6-000A95BCAFA8
- B37F2E1A-C35F-11D9-AB2C-000A95BCAFA8
- F41366B2-C373-11D9-8A81-000A95BCAFA8
- 7C0F8C08-8860-4DBB-AB24-652B53E63E13
- 54CDB56E-85EA-11D9-B369-000A95E13C98
- 776163E4-730B-11D9-BCD0-000D93589AF6
- 200ED3B8-A64B-11D9-B384-000D93382786
- 7DE18A58-37A7-4F6B-8059-4365DCF27E46
- AD6BAC7C-A52E-11D9-8CF2-000D93589AF6
- 9D896CE5-A52E-11D9-8CF2-000D93589AF6
- A72CBA80-5F10-11D9-9B72-000D93589AF6
- 73EAE95D-A09C-4FC2-B4E3-42505678B57E
- 0526D870-BE98-4931-8DBF-FDD3D405BB1B
- 3050DE46-2337-476A-B733-8063B61ECB63
- FCBE2215-19CA-470A-8D92-BB0D00491D62
- E115C756-C345-49A2-B35A-6B97109D360E
- DB57A67F-FD5D-49A2-98E6-8BEAB1D4686D
- 9AC77FC1-5C08-43D6-8ECF-7E42BA71949D
- 05DF9B5B-AB88-4597-ACD3-DD1DCEDC0BE8
- 175D3D76-74CE-11D9-813D-000A95A89C98
- A1DEEFE4-7E3A-11D9-81A1-000A95A89C98
- 01F140D9-749F-11D9-8199-000A95A89C98
- BA4B9C28-6566-46E8-8482-9A52DCB5384D
- 18D4CF4B-2363-412E-B396-6E33868B2EE4
- B9F3EC5C-B299-11D9-9356-0011242E4184
- 8C299FDF-E050-4AFE-A306-491DC4C4A11A
- E8EE6110-2DBA-4FC1-807B-9B19B5DE6737
- 40EF180F-B8AE-40F7-8237-40A53314B57C
- 55048B05-38AA-4B6C-A83C-7F6190F53B6C
- 56BE2092-806D-11D9-A0FB-0011242E4184
- 0CE6FB29-8467-11D9-ABBA-0011242E4184
- 32E15B26-B444-11D9-8D63-000A95A89C98
- 37135380-74CE-11D9-813D-000A95A89C98
- DF784C33-74D7-11D9-813D-000A95A89C98
- 11D4D7C2-7665-11D9-B58C-000A95A89C98
- C7802039-B3C4-11D9-8D63-000A95A89C98
- 5F2BCB27-7A5B-11D9-A61B-000A95A89C98
- 03E4CAA8-0F74-4394-8709-4EF0E22F908B
- 37113D20-778A-11D9-B053-0011242E4184
- CB149C8E-74CD-11D9-813D-000A95A89C98
- 14C1643E-7D51-11D9-859D-000D93B6E43C
- D2F7F545-5149-47B9-AC62-DBDC6ACAB9BB
- 46C3E5A1-7E04-11D9-AE69-000D93B6E43C
- BA9A2B17-DA89-49A5-809B-AC7510C24625
- C9CAF012-6E50-11D9-AA12-000D93589AF6
- BC8B89E4-5F16-11D9-B9C3-000D93589AF6
- 3D7504EE-B927-4D3D-A3CC-BFB189027EE7
- F22BEB71-2DE3-4183-BB10-0199CC328169
- FB8960DB-AA2E-11D9-8E27-000D93589AF6
- AA202E76-8A0A-11D9-B85D-000D93589AF6
- 0F8C1F78-6E4C-11D9-91AF-000D93589AF6
- BEC25DC3-6E4B-11D9-91AF-000D93589AF6
- D26BEEE3-7439-4B7E-AD9D-9A144CDC5873
- 273853DF-6E4F-11D9-A18D-000D93589AF6
- 3010E2A8-6E4F-11D9-A18D-000D93589AF6
- 8085013F-8DEA-11D9-B421-000D93589AF6
- D39DC176-BC8D-11D9-8946-000D93589AF6
- C46A9DBC-0B06-49DF-838B-491B529ECF22
- DA5AD0D9-F7C0-4010-9FDC-FF01B0434F9A
- 4B22577B-BC8E-11D9-8946-000D93589AF6
- 8109F2C2-FF63-46F7-83F3-D2318290FC11
- 965DF29E-4EBD-457A-9A61-56D920C35F72
- 7C9736B2-B851-11D9-B05D-00039369B986
- 3AA8A593-6E4C-11D9-91AF-000D93589AF6
- 3E8C2307-8175-4A58-BE07-785713D5837A
- DA0A4E77-5F16-11D9-B9C3-000D93589AF6
- 48976460-B5A4-11D9-87C9-000D93589AF6
- 970BA294-B667-11D9-8D53-00039369B986
- E5142394-B07A-11D9-8EC4-000D93589AF6
- 5F225755-5840-44CF-BC26-2D484DE833A0
- 6E779E48-F146-49BF-B60C-EFDFD1380772
- 61F92184-1A50-4310-9F75-C9CD2C8819FA
- ADFED53B-16EC-4956-A6A7-3EA2B8140F86
- 4981F52A-F663-45FC-AE25-EE211E88BA05
- 950B3108-E2E3-414E-9C4C-EE068F59A895
- 7AE6F783-F162-4063-850D-1441441849D8
- ED204720-38FC-427C-B91E-D6AE866DAE3A
- F9CD7A8F-9EE9-483B-86BE-12D576AFC036
- C958B58A-D4D4-4055-89DF-22BCA3B8A9CA
- C4006FCA-85FF-4476-BDA8-34EF355FD0E4
- 91FC4F89-ADA9-4435-B159-9BA348FDE590
- A0F5745D-6DC1-4D2B-B638-8A38AB18EE68
- 907BF622-2B0E-43C7-85F6-369A67226CA4
- 61B9EE59-3C49-45B8-94DE-7C0C8BCB965C
- 67E7372F-C15F-4009-AE5B-975F2BC9DD91
- 40D3C674-40A1-42A1-847A-FBEAE6E83CCC
- 779DEA3C-D310-4B66-9531-DF9007434878
- 8104FD3A-DD58-45CA-8FC8-F64680261F13
- 73E356A1-87CF-4B8E-A4B5-B14F29683F12
- F1FD7DF4-975A-4832-8A52-873AA0D32C44
- 775EC3D9-4799-4454-85E5-5112EFCC2A15
- 31F1A06C-0990-4BD7-8E63-D65E7BCD485D
- 392068ED-4C79-42D8-9DE8-53867928B3B0
- 9656317E-73EB-11D9-9848-000D93589AF6
- B0254A99-7750-4A06-937A-9A453ECE3A6C
- E435839A-880B-4E5F-9078-71BC595F2EA0
- 02E5581D-BCC8-4479-A9A9-A5E7CEE8293E
- BED3AE43-7F29-4F92-B2F1-3361B4ACC71A
- E7E68111-54E4-4C01-8DBA-9D9FFD38FF2C
- 83560C23-63E2-4920-8E26-7EAC5FE86B2F
