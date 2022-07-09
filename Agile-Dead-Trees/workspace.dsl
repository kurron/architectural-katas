workspace {
    !docs documentation
    !adrs decisions

    model {
        enterprise "Books R Us" {
            reviewer = person "Reviewer" "Publisher employess (dozens)"
            author = person "Author" "Book authors (hundreds)"
            customer = person "Buyer" "Book purchasers (millions)"
            database = container "Database" "Chapter storage" "Neo4J"
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
            }
        }

        group "External Organizations" {
            container "Marketing" "Gets the word out" "Marketing R Us"
            container "Distribution" "Ships physical books" "Distribution R Us"
            container "Royalties" "Handles royalty payments" "Royalties R Us"
            container "Printing" "Handles printing physical books" "Printing R Us"
            email = softwareSystem "E-Mail Service" "Handles sending out e-mail" "External vendor" {
                this -> customer "notified of new chapters" "e-mail"
                this -> reviewer "notified of new chapters" "e-mail"
                this -> author "notified of reviewer changes" "e-mail"
            }
        }

        customer -> wip "reads new chapters" "web browser"
        authoring -> email "notified of new chapters" "REST API"
        authoring -> email "notified of reviewer changes" "REST API"
        wip -> email "notified of new chapters" "REST API"
    }

    views {
        systemLandscape "system-landscape" "Corporate view" {
            include *
            autoLayout lr
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