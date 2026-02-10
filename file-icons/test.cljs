(ns myapp.components
  (:require [reagent.core :as r]
            [clojure.string :as str]))

(defonce app-state (r/atom {:count 0
                            :items []}))

(defn increment-count []
  (swap! app-state update :count inc))

(defn add-item [text]
  (when-not (str/blank? text)
    (swap! app-state update :items conj
           {:id (random-uuid)
            :text text
            :done false})))

(defn todo-item [{:keys [id text done]}]
  [:li {:class (when done "completed")}
   [:input {:type "checkbox"
            :checked done
            :on-change #(swap! app-state update :items
                               (fn [items]
                                 (mapv (fn [item]
                                         (if (= (:id item) id)
                                           (update item :done not)
                                           item))
                                       items)))}]
   [:span text]])
