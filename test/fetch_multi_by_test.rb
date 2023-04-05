# frozen_string_literal: true

require "test_helper"

class FetchMultiByTest < IdentityCache::TestCase
  NAMESPACE = IdentityCache::CacheKeyGeneration::DEFAULT_NAMESPACE

  def setup
    super
    @bob = Item.new
    @bob.id = 1
    @bob.item_id = 100
    @bob.title = "bob"

    @bertha = Item.new
    @bertha.id = 2
    @bertha.item_id = 100
    @bertha.title = "bertha"
  end

  def test_fetch_multi_by_cache_key
    Item.cache_index(:title, unique: false)

    @bob.save!
    @bertha.save!

    assert_equal([@bob], Item.fetch_by_title("bob"))

    assert_equal([@bob, @bertha], Item.fetch_multi_by_title(["bob", "bertha"]))
  end

  def test_fetch_multi_by_cache_key_with_unknown_key
    Item.cache_index(:title, unique: false)

    @bob.save!
    @bertha.save!

    assert_equal([@bob], Item.fetch_multi_by_title(["bob", "garbage_title"]))
  end

  def test_fetch_multi_by_unique_cache_key
    Item.cache_index(:title, unique: true)

    @bob.save!
    @bertha.save!

    assert_equal(@bob, Item.fetch_by_title("bob"))

    assert_equal([@bob, @bertha], Item.fetch_multi_by_title(["bob", "bertha"]))
  end

  def test_fetch_multi_attribute_by_cache_key
    Item.cache_attribute(:title, by: :id, unique: false)

    @bob.save!
    @bertha.save!

    assert_equal(["bob"], Item.fetch_title_by_id(1))

    assert_equal({ 1 => ["bob"], 2 => ["bertha"] }, Item.fetch_multi_title_by_id([1, 2]))
  end

  def test_fetch_multi_attribute_by_cache_key_with_unknown_key
    Item.cache_attribute(:title, by: :id, unique: false)

    @bob.save!
    @bertha.save!

    assert_equal({ 1 => ["bob"], 999 => [] }, Item.fetch_multi_title_by_id([1, 999]))
  end

  def test_fetch_multi_attribute_by_unique_cache_key
    Item.cache_attribute(:title, by: :id, unique: true)

    @bob.save!
    @bertha.save!

    assert_equal("bob", Item.fetch_title_by_id(1))

    assert_equal({ 1 => "bob", 2 => "bertha" }, Item.fetch_multi_title_by_id([1, 2]))
  end

  def test_fetch_multi_attribute_by_unique_cache_key_with_unknown_key
    Item.cache_attribute(:title, by: :id, unique: true)

    @bob.save!
    @bertha.save!

    assert_equal({ 1 => "bob", 999 => nil }, Item.fetch_multi_title_by_id([1, 999]))
  end

  def test_fetch_multi_attribute_by_with_composite_key
    Item.cache_index(:id, :title, unique: false)

    @bob.save!
    @bertha.save!

    assert_equal([@bob, @bertha], Item.fetch_multi_by_id_and_title([[1, "bob"], [2, "bertha"]]))
  end

  def test_fetch_multi_attribute_by_with_composite_key_and_unknown_keys
    Item.cache_index(:id, :title, unique: false)

    @bob.save!
    @bertha.save!

    assert_equal([@bob], Item.fetch_multi_by_id_and_title([[1, "bob"], [999, "bertha"]]))
  end

  def test_fetch_multi_attribute_by_with_composite_key_and_unique_cache_key
    Item.cache_index(:id, :title, unique: true)

    @bob.save!
    @bertha.save!

    assert_equal([@bob, @bertha], Item.fetch_multi_by_id_and_title([[1, "bob"], [2, "bertha"]]))
  end

  def test_fetch_multi_attribute_by_with_mix_of_unique_and_common_attributes
    Item.cache_index(:id, :item_id, :title, unique: true)

    @bob.save!
    @bertha.save!

    assert_equal([@bob, @bertha], Item.fetch_multi_by_id_and_item_id_and_title([[1, 100, "bob"], [2, 100, "bertha"]]))
  end

  def test_fetch_multi_attribute_by_with_empty_keys_without_using_cache
    Item.cache_index(:id, :title, unique: false)

    @bob.save!
    @bertha.save!

    records = Item.transaction { Item.fetch_multi_by_id_and_title([]) }
    assert_equal([], records)
  end

  def test_fetch_multi_attribute_by_with_single_key
    Item.cache_index(:id, :title, unique: false)

    @bob.save!

    records = Item.fetch_multi_by_id_and_title([[1, "bob"]])
    assert_equal([@bob], records)
  end
end
