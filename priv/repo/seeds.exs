# Script for populating the database. You can run it as:
#
#     mix run priv/repo/seeds.exs
#
# Inside the script, you can read and write to any of your
# repositories directly:
#
#     Bookish.Repo.insert!(%Bookish.SomeModel{})
#
# We recommend using the bang functions (`insert!`, `update!`
# and so on) as they will fail if something goes wrong.

# Tags

ruby = Bookish.Repo.insert! %Bookish.Tag{text: "ruby"}
legacy = Bookish.Repo.insert! %Bookish.Tag{text: "legacy code"}
testing = Bookish.Repo.insert! %Bookish.Tag{text: "testing"}
agile = Bookish.Repo.insert! %Bookish.Tag{text: "agile"}
javascript = Bookish.Repo.insert! %Bookish.Tag{text: "javascript"}

books = [
  %Bookish.Book{title: "Working Effectively With Legacy Code", author_firstname: "Michael", author_lastname: "Feathers", year: 2004, tags: [legacy]}, 
  %Bookish.Book{title: "Test Driven Development For Embedded-C", author_firstname: "James W.", author_lastname: "Grenning", year: 2011, tags: [testing]}, 
  %Bookish.Book{title: "Agile Testing: A Practical Guide for Testers and Agile Teams", author_firstname: "Lisa", author_lastname: "Crispin", year: 2009, tags: [testing, agile]}, 
  %Bookish.Book{title: "Enterprise Software Delivery: Bringing Agility and Efficiency to the Global Software Supply Chain", author_firstname: "Alan W.", author_lastname: "Brown", year: 2012, tags: [agile]},
  %Bookish.Book{title: "Ethical Issues in Business: A Philosophical Approach (7th Edition)", author_firstname: "Thomas", author_lastname: "Donaldson", year: 2001}]


Enum.each(books, fn(book) ->
  Bookish.Repo.insert! book
end)
