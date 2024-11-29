;; RecipeToken - it is a simple Clarity smart contract for storing favorite recipes

;; Define constants for error codes
(define-constant ERR-ALREADY-EXISTS u1)
(define-constant ERR-NOT-FOUND u2)
(define-constant ERR-INVALID-INPUT u3)

;; Define the maximum length for a recipe name
(define-constant MAX-RECIPE-LENGTH u50)

;; Define the map to store recipes
(define-map recipes principal (string-utf8 50))

;; Function to add a new recipe
(define-public (add-recipe (user principal) (recipe-name (string-utf8 50)))
  (let ((name-length (len recipe-name)))
    (if (and (> name-length u0) (<= name-length MAX-RECIPE-LENGTH))
        (if (is-none (map-get? recipes user))
            (begin
              (map-set recipes user recipe-name)
              (ok "Recipe added successfully"))
            (err ERR-ALREADY-EXISTS))
        (err ERR-INVALID-INPUT))))

;; Function to get a recipe
(define-public (get-recipe (user principal))
  (match (map-get? recipes user)
    recipe (ok recipe)
    (err ERR-NOT-FOUND)))

;; Function to update a recipe
(define-public (update-recipe (user principal) (recipe-name (string-utf8 50)))
  (let ((name-length (len recipe-name)))
    (if (and (> name-length u0) (<= name-length MAX-RECIPE-LENGTH))
        (if (is-some (map-get? recipes user))
            (begin
              (map-set recipes user recipe-name)
              (ok "Recipe updated successfully"))
            (err ERR-NOT-FOUND))
        (err ERR-INVALID-INPUT))))

;; Function to delete a recipe
(define-public (delete-recipe (user principal))
  (if (is-some (map-get? recipes user))
      (begin
        (map-delete recipes user)
        (ok "Recipe deleted successfully"))
      (err ERR-NOT-FOUND)))