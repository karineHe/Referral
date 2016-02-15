class User < ActiveRecord::Base
  has_many :godchildren, foreign_key: 'godfather_id', class_name: 'User'
  belongs_to :godfather, class_name: 'User'

  attr_accessor :godfather_username

  before_validation :assign_godfather
  after_find :assign_load_godfather
  before_destroy :assign_gf_to_gch

  validates :username, presence: true, uniqueness: true

  validate :godfather_name, :validate_check_loop

  def godfather_name
    errors.add(:base, "Le username du parrain n'existe pas") if !(godfather_username.blank?) && godfather.blank?
  end

  def assign_godfather
    self.godfather = User.where("lower(username) = ? ", godfather_username.downcase)[0] if !(godfather_username.blank?)
  end

  def validate_check_loop
    check_loop(self)
  end

  def check_loop(user)
    user.godchildren.each do |godchild|
      if godchild.username == godfather_username
        errors.add(:base, "Le parrain ne peut etre un filleul ou un descendant")
        break
      else
        check_loop(godchild)
      end
    end
  end

  def init_godfather_name
    current_user = self
    while !(current_user.godfather.blank?) do
      current_user = current_user.godfather
    end
    current_user.username
  end

  def assign_load_godfather
    if self.godfather
      self.godfather_username = self.godfather.username
    end
  end

  def assign_gf_to_gch
    if self.godchildren.count > 0
      self.godchildren.each do |godchild|
        godchild.godfather = self.godfather
        godchild.godfather_username = nil
        godchild.save
      end
    end
  end

end
