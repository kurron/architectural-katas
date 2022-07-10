workspace {
    !docs documentation
    !adrs decisions

    model {
        group "External Organizations" {
            marketing = softwareSystem "Marketing" "Gets the word out" "Marketing R Us"
            distirbution = softwareSystem "Distribution" "Ships physical books" "Distribution R Us"
            royalties = softwareSystem "Royalties" "Handles royalty payments" "Royalties R Us"
            printing = softwareSystem "Printing" "Handles printing physical books" "Printing R Us"
            email = softwareSystem "E-Mail Service" "Handles sending out e-mail" "External vendor"
        }

        enterprise "Books R Us" {
            reviewer = person "Reviewer" "Publisher employees (dozens)"
            author = person "Author" "Book authors (hundreds)"
            customer = person "Buyer" "Book purchasers (millions)"
            marketer = person "Marketer" "Publisher employees (dozens)"
            pm = person "Project Manager" "Publisher employees (dozens)"
            cms = softwareSystem "Content Management System" {
                container "Purchasing Services" "Handles purchasing of books" "Spring Boot" {
                    customer -> this "purchases books from" "web browser"
                }
                wip = container "WIP Services" "Handles pushing chapters as they become available" "Spring Boot"
                authoring = container "Authoring Services" "Handles books in progress" "Spring Boot" {
                    author -> this "publishes chapters" "web browser"
                    author -> this "reject reviewer changes" "web browser"
                    reviewer -> this "reviews chapters" "web browser"
                    this -> wip "notified of completed chapter" "AMQP"
                }
                database = container "Database" "Chapter storage" "Neo4J"
            }
            marketer -> marketing "specifies marketing campaign" "e-mail"
            pm -> distirbution "specifies distribution plan" "e-mail"
            pm -> printing "specifies printing plan" "e-mail"
            pm -> royalties "specifies royalty payments" "e-mail/spreadsheet"
        }


        email -> author "notified of reviewer changes" "e-mail"
        email -> reviewer "notified of new chapters" "e-mail"
        email -> customer "notified of new chapters" "e-mail"
        customer -> wip "reads new chapters" "web browser"
        authoring -> email "notified of new chapters" "REST API"
        authoring -> email "notified of reviewer changes" "REST API"
        wip -> email "notified of new chapters" "REST API"
    }

    views {
        systemLandscape "system-landscape" "Corporate view" {
            include *
            autoLayout tb
        }

        systemContext cms {
            include *
            #autolayout lr
        }

        container cms {
            include *
            #autolayout lr
        }

        dynamic "cms" {
            title "New Chapter (approved)"
            autoLayout lr
            author -> authoring "publishes chapters" "web browser"
            authoring -> email "notified of new chapters" "REST API"
            email -> reviewer "notified of new chapters" "e-mail"
            reviewer -> authoring "reviews and approves new chapters" "web browser"
            authoring -> wip "notified of completed chapter" "AMQP"
            wip -> email "notified of new chapters" "REST API"
            email -> customer "notified of new chapters" "e-mail"
            customer -> wip "reads new chapters" "web browser"
        }

        theme default
    }

}