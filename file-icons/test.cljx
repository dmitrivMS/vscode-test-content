(ns myapp.util
  #+clj  (:require [clojure.string :as str])
  #+cljs (:require [clojure.string :as str]))

(defn uuid []
  #+clj  (str (java.util.UUID/randomUUID))
  #+cljs (str (random-uuid)))

(defn now-ms []
  #+clj  (System/currentTimeMillis)
  #+cljs (.getTime (js/Date.)))

(defn parse-int [s]
  #+clj  (Integer/parseInt s)
  #+cljs (js/parseInt s 10))

(defn slugify [text]
  (-> text
      str/lower-case
      str/trim
      (str/replace #"[^\w\s-]" "")
      (str/replace #"[\s_]+" "-")))

(defn truncate [s max-len]
  (if (<= (count s) max-len)
    s
    (str (subs s 0 (- max-len 3)) "...")))
