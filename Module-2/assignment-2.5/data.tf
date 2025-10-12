# Sample Data for Book Inventory Table

resource "aws_dynamodb_table_item" "book1" {
  table_name = aws_dynamodb_table.book_inventory.name
  hash_key   = "ISBN"
  range_key  = "Genre"

  item = jsonencode({
    ISBN   = { S = "978-0134685991" }
    Genre  = { S = "Technology" }
    Title  = { S = "Effective Java" }
    Author = { S = "Joshua Bloch" }
    Stock  = { N = "1" }
  })
}

resource "aws_dynamodb_table_item" "book2" {
  table_name = aws_dynamodb_table.book_inventory.name
  hash_key   = "ISBN"
  range_key  = "Genre"

  item = jsonencode({
    ISBN   = { S = "978-0134685009" }
    Genre  = { S = "Technology" }
    Title  = { S = "Learning Python" }
    Author = { S = "Mark Lutz" }
    Stock  = { N = "2" }
  })
}

resource "aws_dynamodb_table_item" "book3" {
  table_name = aws_dynamodb_table.book_inventory.name
  hash_key   = "ISBN"
  range_key  = "Genre"

  item = jsonencode({
    ISBN   = { S = "974-0134789698" }
    Genre  = { S = "Fiction" }
    Title  = { S = "The Hitchhiker" }
    Author = { S = "Douglas Adams" }
    Stock  = { N = "10" }
  })
}

resource "aws_dynamodb_table_item" "book4" {
  table_name = aws_dynamodb_table.book_inventory.name
  hash_key   = "ISBN"
  range_key  = "Genre"

  item = jsonencode({
    ISBN   = { S = "982-01346653457" }
    Genre  = { S = "Fiction" }
    Title  = { S = "Dune" }
    Author = { S = "Frank Herbert" }
    Stock  = { N = "8" }
  })
}

resource "aws_dynamodb_table_item" "book5" {
  table_name = aws_dynamodb_table.book_inventory.name
  hash_key   = "ISBN"
  range_key  = "Genre"

  item = jsonencode({
    ISBN   = { S = "978-01346854325" }
    Genre  = { S = "Technology" }
    Title  = { S = "System Design" }
    Author = { S = "Mark Lutz" }
  })
}
