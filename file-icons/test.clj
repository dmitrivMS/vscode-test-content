(ns myapp.core
  (:require [clojure.string :as str]
            [clojure.java.io :as io]))

(defn parse-csv-line [line]
  (mapv str/trim (str/split line #",")))

(defn read-csv [filename]
  (with-open [reader (io/reader filename)]
    (let [lines (line-seq reader)
          header (parse-csv-line (first lines))
          rows (map parse-csv-line (rest lines))]
      (mapv #(zipmap header %) rows))))

(defn filter-by-field [records field value]
  (filter #(= (get % field) value) records))

(defn -main [& args]
  (let [filename (first args)
        records (read-csv filename)
        active (filter-by-field records "status" "active")]
    (println (str "Total records: " (count records)))
    (println (str "Active records: " (count active)))))
