class Experiment
  def self.new_article_pair(experiment, control)
    experiment.save!
    control.save!
    experiment.update!(experiment_condition: Article::EXPERIMENT, experiment_pair_id: control.id)
    control.update!(experiment_condition: Article::CONTROL, experiment_pair_id: experiment.id)
  end
end
