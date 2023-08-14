-- Returns full contacts with given ids.
--
--   $ osascript brief.applescript [contact_id_1] [contact_id_2] ... [contact_id_N]
--   stdout:
--   [
--     {
--       "contact_id": "[contact_id_1]",
--       "name": "[name_1]",
--       ...
--       "notes": "[notes_1]"
--     },
--     {
--       "contact_id": "[contact_id_2]",
--       "name": "[name_2]",
--       ...
--       "notes": "[notes_2]"
--     },
--     ...
--     {
--       "contact_id": "[contact_id_N]",
--       "name": "[name_N]",
--       ...
--       "notes": "[notes_N]"
--     }
--   ]


on findAndReplaceInText(theText, theSearchString, theReplacementString)
    set AppleScript's text item delimiters to theSearchString
    set theTextItems to every text item of theText
    set AppleScript's text item delimiters to theReplacementString
    set theText to theTextItems as string
    set AppleScript's text item delimiters to ""
    return theText
end


on encloseList(theOpening, theIndent, theList, theClosing)
    set theInner to {}
    repeat with theLine in theList
        if class of theLine is text
            copy theIndent & theLine as text to the end of theInner
        end if
    end repeat
    if count of theInner = 0
        return theOpening & "\n" & theClosing
    else
        set AppleScript's text item delimiters to ",\n"
        set theInner to theInner as text
        set AppleScript's text item delimiters to ""
        return theOpening & "\n" & theInner & "\n" & theClosing
    end if
end


on logContactValue(theName, theValue)
    tell application "Contacts"
        if exists theValue
            if class of theValue is text
                set theValue to my findAndReplaceInText(theValue, "\\n", "\\\\n")
                set theValue to my findAndReplaceInText(theValue, "\n", "\\n")
                set theValue to "\"" & theValue & "\""
            end if
            return "\"" & theName & "\": " & theValue
        end if
    end tell
end logContactValue


on logContactDate(theName, theDate)
    tell application "Contacts"
        if year of theDate >= 1900
            set theDateStr to (month of theDate) & " " & (day of theDate) & ", " & (year of theDate)
        else
            set theDateStr to (month of theDate) & " " & (day of theDate)
        end if
        return my logContactValue(theName, theDateStr as text)
    end tell
end


on logContactInfo(theName, theInfos, areDates)
    tell application "Contacts"
        if count of theInfos > 0
            set theResults to {}

            repeat with theInfo in theInfos
                set theEntries to {}

                copy my logContactValue("info_id", id of theInfo) to the end of theEntries
                copy my logContactValue("label", label of theInfo) to the end of theEntries
                if areDates
                    copy my logContactDate("value", value of theInfo) to the end of theEntries
                else
                    copy my logContactValue("value", value of theInfo) to the end of theEntries
                end if

                copy my encloseList("    {", "        ", theEntries, "      }") to the end of theResults
            end repeat

            return my encloseList("\"" & theName & "\": [", "  ", theResults, "    ]")
        end if
    end tell
end


on logContactSocialProfiles(theContact)
    tell application "Contacts"
        set theSocialProfiles to every social profile of theContact
        if count of theSocialProfiles > 0
            set theResults to {}

            repeat with theSocialProfile in theSocialProfiles
                set theEntries to {}

                copy my logContactValue("info_id", id of theSocialProfile) to the end of theEntries
                copy my logContactValue("label", service name of theSocialProfile) to the end of theEntries
                copy my logContactValue("value", user name of theSocialProfile) to the end of theEntries
                copy my logContactValue("user_identifier", user identifier of theSocialProfile) to the end of theEntries
                copy my logContactValue("url", url of theSocialProfile) to the end of theEntries

                copy my encloseList("    {", "        ", theEntries, "      }") to the end of theResults
            end repeat

            return my encloseList("\"social_profiles\": [", "  ", theResults, "    ]")
        end if
    end tell
end


on logInstantMessages(theContact)
    tell application "Contacts"
        set theInstantMessages to every instant message of theContact
        if count of theInstantMessages > 0
            set theResults to {}

            repeat with theInstantMessage in every instant message of theContact
                set theEntries to {}

                --- value is missing
                copy my logContactValue("info_id", id of theInstantMessage) to the end of theEntries
                copy my logContactValue("label", service name of theInstantMessage) to the end of theEntries
                copy my logContactValue("value", user name of theInstantMessage) to the end of theEntries

                copy my encloseList("    {", "        ", theEntries, "      }") to the end of theResults
            end repeat

            return my encloseList("\"instant_messages\": [", "  ", theResults, "    ]")
        end if
    end tell
end


on logContactAddresses(theContact)
    tell application "Contacts"
        set theAddresses to every address of theContact
        if count of theAddresses > 0
            set theResults to {}

            repeat with theAddress in every address of theContact
                set theEntries to {}

                copy my logContactValue("info_id", id of theAddress) to the end of theEntries
                copy my logContactValue("label", label of theAddress) to the end of theEntries
                copy my logContactValue("value", formatted address of theAddress) to the end of theEntries
                copy my logContactValue("country_code", country code of theAddress) to the end of theEntries
                copy my logContactValue("street", street of theAddress) to the end of theEntries
                copy my logContactValue("city", city of theAddress) to the end of theEntries
                copy my logContactValue("state", state of theAddress) to the end of theEntries
                copy my logContactValue("zip_code", zip of theAddress) to the end of theEntries
                copy my logContactValue("country", country of theAddress) to the end of theEntries

                copy my encloseList("    {", "        ", theEntries, "      }") to the end of theResults
            end repeat

            return my encloseList("\"addresses\": [", "  ", theResults, "    ]")
        end if
    end tell
end


on logContactBirthDate(theContact)
    tell application "Contacts"
        set theBirthDate to birth date of theContact
        if theBirthDate exists
            return my logContactDate("birth_date", theBirthDate)
        end if
    end tell
end


on detailContact(theIds)
    tell application "Contacts"
        set theResults to {}

        repeat with theId in theIds
            set theEntries to {}

            set theContact to person id theId
            set theEntries to {}

            tell theContact
                copy my logContactValue("contact_id", id) to the end of theEntries

                copy my logContactValue("name", name) to the end of theEntries
                copy my logContactValue("has_image", image of theContact exists) to the end of theEntries
                copy my logContactValue("is_company", company) to the end of theEntries

                copy my logContactValue("prefix", title) to the end of theEntries
                copy my logContactValue("first_name", first name) to the end of theEntries
                copy my logContactValue("phonetic_first_name", phonetic first name) to the end of theEntries
                copy my logContactValue("middle_name", middle name) to the end of theEntries
                copy my logContactValue("phonetic_middle_name", phonetic middle name) to the end of theEntries
                copy my logContactValue("last_name", last name) to the end of theEntries
                copy my logContactValue("phonetic_last_name", phonetic last name) to the end of theEntries
                copy my logContactValue("maiden_name", maiden name) to the end of theEntries
                copy my logContactValue("suffix", suffix) to the end of theEntries
                copy my logContactValue("nickname", nickname) to the end of theEntries

                copy my logContactValue("job_title", job title) to the end of theEntries
                copy my logContactValue("department", department) to the end of theEntries
                copy my logContactValue("organization", organization) to the end of theEntries

                copy my logContactInfo("phones", every phone of theContact, false) to the end of theEntries
                copy my logContactInfo("emails", every email of theContact, false) to the end of theEntries
                copy my logContactValue("home_page", home page) to the end of theEntries
                copy my logContactInfo("urls", every url of theContact, false) to the end of theEntries

                copy my logContactAddresses(theContact) to the end of theEntries

                copy my logContactBirthDate(theContact) to the end of theEntries
                copy my logContactInfo("custom_dates", custom dates of theContact, true) to the end of theEntries

                copy my logContactInfo("related_names", every related names of theContact, false) to the end of theEntries

                copy my logContactSocialProfiles(theContact) to the end of theEntries
                copy my logInstantMessages(theContact) to the end of theEntries

                copy my logContactValue("note", note) to the end of theEntries
            end tell

            copy my encloseList(" {", "    ", theEntries, "  }") to the end of theResults
        end repeat

        return my encloseList("[", " ", theResults, "]")
    end tell
end


on run argv
    detailContact(argv)
end
